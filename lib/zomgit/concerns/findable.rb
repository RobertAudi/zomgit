module Zomgit
  module Concerns
    module Findable
      class Finder
        # IMPROVE: Permit the query to be more complex (e.g.: a regex)
        def self.fuzzy_find(files, query, options = {})
          return Array.new if query.empty?

          eager_pattern = "\\b#{Regexp.escape(query)}"

          if query.include?("/")
            greedy_pattern = query.split("/").map { |p| p.split("").map { |c| Regexp.escape(c) }.join(")[^\/]*?(").prepend("[^\/]*?(") + ")[^\/]*?" }.join("\/")
            greedy_pattern << "\/" if query[-1] == "/"
          else
            greedy_pattern = query.split("").map { |c| Regexp.escape(c) }.join(").*?(").prepend(".*?(") + ").*?"
          end

          eager_results = []
          greedy_results = []
          exact_match_found = false

          files.each do |f|
            if f =~ /#{eager_pattern}/
              eager_results << f
              exact_match_found = true
              next
            end

            if exact_match_found
              next unless !!options[:greedy]
            end

            greedy_results << f if f =~ /#{greedy_pattern}/
          end

          if eager_results.empty? || !!options[:greedy]
            eager_results + greedy_results
          else
            eager_results
          end
        end
      end

      def find(arguments, options = [])
        greedy = !!options[:greedy]
        clean = !!options[:clean]

        case options[:filter].to_sym
        when :all
          cmds = ["ls-files --others --cached --exclude-standard"]
        when :untracked
          cmds = ["ls-files --others --exclude-standard"]
        when :tracked
          cmds = ["ls-files"]
        when :unstaged
          cmds = ["ls-files --others --exclude-standard", "diff --name-only"]
        when :modified
          cmds = ["diff --name-only"]
        else
          cmds = ["ls-files --others --cached --exclude-standard"]
        end

        files = Array.new
        cmds.each { |c| files << `command git #{c}`.split("\n") }
        files.flatten!

        if clean
          found = files

          arguments.each do |arg|
            found = Finder.fuzzy_find(found, arg, greedy: greedy)
          end
        else
          found = Array.new

          arguments.each do |arg|
            found << Finder.fuzzy_find(files, arg, greedy: greedy)
          end

          found = found.flatten.uniq
        end

        found
      end
    end
  end
end