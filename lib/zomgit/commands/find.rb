module Zomgit
  module Commands
    class FindCommand < BasicCommand
      include Zomgit::Concerns::Findable

      DESCRIPTION = "Find files in the git repo"
      SWITCHES = {
        %i(greedy g) => {
          default_value: true,
          negatable: true,
          desc: "Let the finder be greedy (less accurate, more results)"
        },
        %i(G) => {
          default_value: false,
          negatable: false,
          desc: "Alias to --no-greedy",
        },
        %i(r refine) => {
          default_value: false,
          negatable: false,
          desc: "Let the finder be selective (more accurate, less results)"
        }
      }

      FLAGS = {
        %i(filter f) => {
          arg_name: "filter",
          desc: "Limit the search to a specific state (tracked, untracked, etc)",
          must_match: %w(all untracked tracked unstaged modified),
          default_value: :all
        }
      }

      def find
        if self.arguments.empty?
          raise Zomgit::Exceptions::MissingQueryError.new("You need to supply a search query!")
        end

        files = self.search(arguments, options)

        if files.empty?
          raise Zomgit::Exceptions::FileOrDirectoryNotFoundError.new("Nothing found matching your query")
        end

        files.join("\n")
      end
      alias_method Zomgit::Commands::EXECUTION_METHOD, :find

    end
  end
end
