module Zomgit
  module Commands
    class AddCommand < BasicCommand
      include Zomgit::Concerns::Findable
      include Zomgit::Helpers::RainbowHelper

      DESCRIPTION = "Add stuff to the staging area"
      FLAGS = {
        %i(filter f) => {
          arg_name: "filter",
          desc: "Addition filter",
          must_match: %w(untracked unstaged modified),
          default_value: "unstaged"
        }
      }

      def add
        files = self.find(arguments, options)

        if files.empty?
          raise Zomgit::Exceptions::FileOrDirectoryNotFoundError.new("Nothing to add matching this filter")
        end

        system "command git add --all #{files.join(" ")}"

        Zomgit::Persistor.instance.clean_index_cache!
        Zomgit::Commands::StatusCommand.new.send(Zomgit::Commands::EXECUTION_METHOD)
      end
      alias_method Zomgit::Commands::EXECUTION_METHOD, :add

    end
  end
end
