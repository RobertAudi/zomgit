# Dev shit
if ENV["ZOMGIT_DEBUG_MODE"] == "enabled"
  require "awesome_print" rescue nil
end

# Require gems shit
require "gli"
require "rainbow/ext/string"


%w(helpers concerns).each { |f| Dir.glob(File.join(File.dirname(File.realpath(__FILE__)), "zomgit", f, "*.rb")).each { |ff| require ff } }

require_relative File.join(".", "zomgit", "version")
require_relative File.join(".", "zomgit", "persistor")
require_relative File.join(".", "zomgit", "exceptions")
require_relative File.join(".", "zomgit", "commands")

module Zomgit
  def project_root
    @project_root
  end
  module_function :project_root

  def project_root=(value)
    if value.empty?
      raise Zomgit::Exceptions::NoGitRepoFoundError.new("Directory is not a git repository (#{Dir.getwd})")
    end

    @project_root = value
  end
  module_function :project_root=

  class CLI
    extend GLI::App

    program_desc  "git wrapper for the Z shell"
    version       Zomgit::VERSION

    pre do |global_options,command,options,args|
      Zomgit::project_root = File.directory?(File.join(Dir.getwd, ".git")) ? Dir.getwd : `\git rev-parse --show-toplevel 2> /dev/null`.strip
    end

    Zomgit::Commands::LIST.each do |cname|
      cmd = Zomgit::Commands.const_get("#{cname.capitalize}Command")

      desc cmd::DESCRIPTION
      command cname do |c|
        if cmd.const_defined?("FLAGS")
          cmd::FLAGS.each { |names, params| c.flag(*names, params) }
        end

        if cmd.const_defined?("SWITCHES")
          cmd::SWITCHES.each { |names, params| c.switch(*names, params) }
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
