# Dev shit
if ENV["ZOMGIT_DEBUG_MODE"] == "enabled"
  require "awesome_print" rescue nil
end

# Require gems shit
require "gli"
require "rainbow/ext/string"


%w(helpers concerns).each { |f| Dir.glob(File.join(File.dirname(File.realpath(__FILE__)), "zomgit", f, "*.rb")).each { |ff| require ff } }

require_relative File.join(".", "zomgit", "version")
require_relative File.join(".", "zomgit", "exceptions")
require_relative File.join(".", "zomgit", "commands")

module Zomgit
  class CLI
    extend GLI::App

    program_desc  "git wrapper for the Z shell"
    version       Zomgit::VERSION

    Zomgit::Commands::LIST.each do |cname|
      cmd = Zomgit::Commands.const_get("#{cname.capitalize}Command")

      desc cmd::DESCRIPTION
      command cname do |c|
        if cmd.const_defined?("FLAGS")
          cmd::FLAGS.each { |names, params| c.flag(*names, params) }
        end

        c.action do |global_options, options, args|
          the_command = cmd.new(args, options)
          puts the_command.send(Zomgit::Commands::EXECUTION_METHOD)
        end
      end
    end

    on_error do |exception|
      case exception
      when Zomgit::Exceptions::BaseError
        $stderr.puts exception.message.color(:red)
        false
      else
        true
      end
    end
  end
end
