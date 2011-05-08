require 'optparse'

module Kerplutz
  class << self
    attr_accessor :configuration

    def configure
      self.configuration = Configuration.new
      yield self.configuration
    end

    def parse!(args)
      # if args[0] !~ /^--/
      #   this is a flag or switch so execute it
      # else we assume this is a command so
      #   find command
      #   execute command, passing args[1..-1] in as the arguments
      # end
      case args.shift
      when "--version"
        configuration.helpcommand.parse("--version")
      when "help"
        puts help_banner
      else
        puts help_banner
      end
    end

    def help_banner
      help = ""
      help << configuration.helpcommand.help
      help << "\n"
      help << " Commands:"
      help << "\n"
      configuration.subcommands.each do |command|
        help << "  #{command.names.join(', ')} #{command.banner}"
      end
      help << "\n\n"
      help << "Type '#{configuration.bin_name} help COMMAND' for help with a specific command.\n"
      help
    end
  end

  class Configuration
    attr_reader   :helpcommand, :subcommands
    attr_accessor :bin_name, :banner

    def initialize
      @subcommands = []
      @helpcommand = Command.new(OptionParser.new, :help)
    end

    def banner=(banner)
      helpcommand.banner = banner
    end

    def action(name, &action)
      helpcommand.action(name, &action)
    end

    def command(*command_aliases)
      parser = OptionParser.new { |opts| yield opts }
      subcommands << Command.new(parser, *command_aliases)
    end
  end

  class Command
    attr_reader :names

    def initialize(parser, *names)
      @parser = parser
      @names = names
    end

    def banner
      @parser.banner
    end
    
    def banner=(text)
      @parser.banner = text
    end

    def action(name, &action)
      @parser.on("--#{name}", &action)
    end

    def help
      @parser.help
    end

    def parse(*args)
      @parser.parse(*args)
    end
  end
end
