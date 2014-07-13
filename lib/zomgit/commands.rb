module Zomgit
  module Commands
    EXECUTION_METHOD = :execute!
    FILES = Dir.glob(File.join(File.dirname(File.realpath(__FILE__)), "commands", "*.rb"))
    LIST = FILES.map { |c| File.basename(c, ".rb") }

    class BasicCommand
      attr_reader :arguments, :options

      def initialize(arguments = [], options = {})
        @arguments = arguments
        @options = options
      end
    end
  end
end

Zomgit::Commands::FILES.each { |f| require f }
