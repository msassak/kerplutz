require 'optparse'

module Kerplutz
  class << self
    def build
      yield builder = Builder.new
      builder.result
    end
  end

  class Builder
    attr_reader   :base
    attr_accessor :program_name, :banner

    def initialize
      @base = Executable.new
    end

    def program_name=(name)
      base.program_name = name
    end

    def program_name
      base.program_name
    end

    def banner=(banner)
      base.banner = banner
    end

    def flag(name, desc)
      base.add_option(Flag.new(name, desc))
    end

    def switch(name, desc)
      base.add_option(Switch.new(name, desc))
    end

    def action(name, &action)
      base.action(name, &action)
    end

    def command(*command_aliases)
      command = Command.new(*command_aliases)
      yield command
      base.commands << command
    end

    def result
      base
    end
  end

  class Option
    attr_reader :name, :desc

    def initialize(name, desc)
      @name = name
      @desc = desc
    end

    def configure(parser)
      raise "You'll need to implement this one yourself, bub."
    end
  end

  class Flag < Option
    def configure(parser, arguments)
      parser.on("--#{name}", desc)
    end
  end

  class Switch < Option
    def configure(parser, arguments)
      parser.on("--[no-]#{name}", desc) do |arg|
        arguments[name] = arg
      end
    end
  end

  class Executable
    attr_reader :commands, :parser, :arguments

    def initialize(arguments={})
      @arguments = arguments
      @commands = []
      @parser = OptionParser.new
    end

    def add_option(option)
      option.configure(parser, arguments)
    end

    def program_name=(name)
      @parser.program_name = name
    end

    def program_name
      @parser.program_name
    end

    def banner=(banner)
      @parser.banner = banner
    end

    def action(name, &action)
      @parser.on("--#{name}", &action)
    end

    def parse(args)
      if args[0] =~ /^--/
        parser.parse(args)
      else
        puts help_banner
      end

      arguments
    end

    def help_banner
      help = ""
      help << @parser.help
      help << "\n"
      help << " Commands:"
      help << "\n"
      commands.each do |command|
        help << "  #{command.names.join(', ')} #{command.banner}\n"
      end
      help << "\n"
      help << "Type '#{program_name} help COMMAND' for help with a specific command.\n"
      help
    end
  end

  class Command
    attr_reader :names

    def initialize(*names)
      @parser = OptionParser.new
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
