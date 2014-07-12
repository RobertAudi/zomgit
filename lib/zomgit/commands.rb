module Zomgit
  module Commands
    EXECUTION_METHOD = :execute!
    FILES = Dir.glob(File.join(File.dirname(File.realpath(__FILE__)), "commands", "*.rb"))
    LIST = FILES.map { |c| File.basename(c, ".rb") }

    class BasicCommand
      attr_reader :arguments, :options

      def initialize(arguments = [], options = {})
        @project_root = File.directory?(File.join(Dir.getwd, ".git")) ? Dir.getwd : `\git rev-parse --show-toplevel 2> /dev/null`.strip

        if @project_root.empty?
          raise Zomgit::Exceptions::NoGitRepoFoundError.new("Directory is not a git repository (#{Dir.getwd})")
        end

        @arguments = arguments
        @options = options
      end
    end
  end
end

Zomgit::Commands::FILES.each { |f| require f }
