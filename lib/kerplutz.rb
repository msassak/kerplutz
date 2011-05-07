require 'optparse'

module Kerplutz
  class << self
    attr_accessor :configuration

    def configure
      self.configuration = Configuration.new
      yield self.configuration
    end

    def parse!(args)
      case args.shift
      when "-h", "--help"
        help = ""
        help << configuration.basecommand.help
        help << "\n"
        help << " Commands:"
        help << "\n"
        configuration.subcommands.each do |command|
          help << "  #{command.names.join(', ')} #{command.banner}"
        end
        puts help
      else
        puts "For help, type: #{configuration.bin_name} -h"
      end
    end
  end

  class Configuration
    attr_reader   :basecommand, :subcommands
    attr_accessor :bin_name, :banner

    def initialize
      @subcommands = []
      @basecommand = OptionParser.new
    end

    def banner=(banner)
      basecommand.banner = banner
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
  end
end
