module Zomgit
  module Commands
    class StatusCommand < BasicCommand
      include Zomgit::Helpers::FileHelper
      include Zomgit::Helpers::RainbowHelper

      attr_reader :filter

      DESCRIPTION = "Show the status of the git repo"
      FLAGS = {
        %i(filter f) => {
          arg_name: "filter",
          desc: "Status filter",
          must_match: %w(staged unmerged unstaged untracked)
        }
      }

      MAX_CHANGES = 150

      COLORS = {
        reset:     [:white,  { bold: false }],
        deleted:   [:red,    { bold: false }],
        modified:  [:green,  { bold: false }],
        added:     [:yellow, { bold: false }],
        renamed:   [:blue,   { bold: false }],
        copied:    [:yellow, { bold: false }],
        retyped:   [:purple, { bold: false }],
        untracked: [:cyan,   { bold: false }],
        dark:      [:black,  { bold: true  }],
        branch:    [:gray,   { bold: true  }],
        header:    [:white,  { bold: false }]
      }

      GROUPS = {
        staged:    { color: :yellow, message:       "Changes to be committed" },
        unmerged:  { color: :red,    message:                "Unmerged paths" },
        unstaged:  { color: :green,  message: "Changes not staged for commit" },
        untracked: { color: :cyan,   message:               "Untracked files" }
      }

      def initialize(arguments = [], options = {})
        super arguments, options

        @filter = options[:filter].to_sym if options[:filter]
      end

      def show
        status = `command git status --porcelain`.split("\n")

        if status.count > self.max_changes
          raise Zomgit::Exceptions::TooManyChangesError.new("Too many changes")
        end

        git_branch_output = `command git branch -v 2> /dev/null`
        branch = git_branch_output[/^\* (\(no branch\)|[^ ]*)/, 1]
        ahead  = git_branch_output[/^\* [^ ]* *[^ ]* *\[ahead ?(\d+).*\]/, 1]
        behind = git_branch_output[/^\* [^ ]* *[^ ]* *\[.*behind ?(\d+)\]/, 1]

        difference = ["-#{behind}", "+#{ahead}"].select{ |diff| diff.length > 1 }.join("/")
        if difference.length > 0
          diff = ""
          diff << dark_color(" | ")
          diff << added_color(difference)
          difference = diff
        else
          difference = ""
        end

        output = ""
        output << dark_color("#")
        output << " On branch: "
        output << branch_color(branch)
        output << difference
        output << dark_color(" | ")

        if status.empty?
          output << modified_color("No changes (working directory clean)\n")
        else
          output << self.stats_for(status).gsub(/(\d+)/, modified_color('\1'))
          output << dark_color("\n#\n")

          changes = self.changes_for status

          if self.has_filter? && GROUPS.has_key?(self.filter)
            if changes[self.filter].empty?
              raise Zomgit::Exceptions::NoChangesError.new("No changes matching this filter")
            else
              output << self.output_for(self.filter, changes[self.filter])
            end
          else
            GROUPS.keys.each { |g| output << self.output_for(g, changes[g]) unless changes[g].empty? }
          end
        end

        output
      end
      alias_method Zomgit::Commands::EXECUTION_METHOD, :show

      # Dynamically create color methods
      # i.e.: `branch_color`
      COLORS.each do |type, spec|
        define_method "#{type}_color" do |message|
          send(spec.first, message, spec.last)
        end
      end

      # Same as above, but for groups
      GROUPS.each do |group, spec|
        define_method "#{group}_group_color" do |message, options = {}|
          send(spec[:color], message, options)
        end
      end

      def max_changes
        unless @max_changes
          max = ENV["ZOMGIT_STATUS_MAX_CHANGES"].to_i
          @max_changes = max > 0 ? max : MAX_CHANGES
        end

        @max_changes
      end

      def has_modules?
        @has_modules ||= File.exists?(File.join(@project_root, ".gitmodules"))
      end

      def has_dirty_module?
        !!@has_dirty_module
      end

      def has_dirty_module!
        @has_dirty_module = true
      end

      def has_filter?
        !self.filter.nil?
      end

      def long_status
        @long_status ||= `command git status`
      end

      def stats_for(status)
        stats = "#{status.count} changes ("
        staged = status.grep(/\A[^ ?]/).count
        unstaged = status.grep(/\A[ ?]/).count
        stats << "#{staged} staged, #{unstaged} unstaged"
        stats << ")"
      end

      def changes_for(status)
        changes = {
          staged:    [],
          unmerged:  [],
          unstaged:  [],
          untracked: []
        }

        modules = self.has_modules? ? File.read(File.join(@project_root, ".gitmodules")) : ""

        status.each do |raw_change|
          change = { left: raw_change[0], right: raw_change[1], file: raw_change[3..-1] }

          # if has_modules? && File.read(File.join(@project_root, ".gitmodules")).include?(change[:file])
          if !self.has_dirty_module? && modules.include?(change[:file])
            self.has_dirty_module!
          end

          case raw_change[0..1]
          when "DD"; changes[:unmerged]  << { message: "   both deleted",  color: :deleted,   file: change[:file] }
          when "AU"; changes[:unmerged]  << { message: "    added by us",  color: :added,     file: change[:file] }
          when "UD"; changes[:unmerged]  << { message: "deleted by them",  color: :deleted,   file: change[:file] }
          when "UA"; changes[:unmerged]  << { message: "  added by them",  color: :added,     file: change[:file] }
          when "DU"; changes[:unmerged]  << { message: "  deleted by us",  color: :deleted,   file: change[:file] }
          when "AA"; changes[:unmerged]  << { message: "     both added",  color: :added,     file: change[:file] }
          when "UU"; changes[:unmerged]  << { message: "  both modified",  color: :modified,  file: change[:file] }
          when /M./; changes[:staged]    << { message: "  modified",       color: :modified,  file: change[:file] }
          when /A./; changes[:staged]    << { message: "  new file",       color: :added,     file: change[:file] }
          when /D./; changes[:staged]    << { message: "   deleted",       color: :deleted,   file: change[:file] }
          when /R./; changes[:staged]    << { message: "   renamed",       color: :renamed,   file: change[:file] }
          when /C./; changes[:staged]    << { message: "    copied",       color: :copied,    file: change[:file] }
          when /T./; changes[:staged]    << { message: "typechange",       color: :retyped,   file: change[:file] }
          when "??"; changes[:untracked] << { message: " untracked",       color: :untracked, file: change[:file] }
          end

          if change[:right] == "M"
            changes[:unstaged] << { message: "  modified", color: :modified, file: change[:file] }
          elsif change[:right] == "D" && change[:left] != "D" && change[:left] != "U"
            changes[:unstaged] << { message: "   deleted", color: :deleted, file: change[:file] }
          elsif change[:right] == "T"
            changes[:unstaged] << { message: "typechange", color: :retyped, file: change[:file] }
          end
        end

        changes
      end

      def output_for(group, changes)
        output = ""

        output << send("#{group}_group_color", "\u27A4".encode("utf-8"), bold: true)
        output << header_color("  #{GROUPS[group][:message]}\n")
        output << send("#{group}_group_color", "#")
        output << "\n"

        changes.each do |change|
          relative_file = relative_path(Dir.pwd, File.join(@project_root, change[:file]))

          submodule_change = nil
          if self.has_dirty_module?
            submodule_change = self.long_status[/#{change[:file]} \((.*)\)/, 1]

            unless submodule_change.nil?
              submodule_change = "(#{submodule_change})"
            end
          end

          output << send("#{group}_group_color", "#     ")
          output << send("#{change[:color]}_color", change[:message])
          output << ": "
          output << send("#{group}_group_color", relative_file)
          output << " #{submodule_change}\n"
        end

        output << send("#{group}_group_color", "#")
        output << "\n"
        output
      end
    end
  end
end
