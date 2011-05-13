require 'optparse'

module Kerplutz
  class << self
    def build(name)
      yield builder = Builder.new(name)
      builder.result
    end
  end

  class Builder
    attr_reader   :base
    attr_accessor :program_name, :banner

    def initialize(name)
      @base = Executable.new(name)
    end

    def program_name
      base.program_name
    end

    def banner=(banner)
      base.banner = banner
    end

    def flag(name, desc="")
      base.add_option(Flag.new(name, desc))
    end

    def switch(name, desc="")
      base.add_option(Switch.new(name, desc))
    end

    def action(name, desc="", &action)
      base.add_option(Action.new(name, desc, &action))
    end

    def command(name, desc="")
      command = Command.new(name, desc)
      yield command
      base.add_command(command)
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

    def configure(parser, arguments)
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

  class Action < Option
    def initialize(name, desc, &action)
      super(name, desc)

      @action = Proc.new do
        action.call
        exit
      end
    end

    def configure(parser, arguments)
      parser.on("--#{name}", desc, &@action)
    end
  end

  class Executable
    attr_reader :commands, :parser, :arguments, :help

    def initialize(name, arguments={})
      @arguments = arguments
      @parser = OptionParser.new
      @parser.program_name = name
      @help = Help.new
      @commands = []
    end

    def add_option(option)
      option.configure(parser, arguments)
    end

    def add_command(command)
      help.register(command)
      commands << command
    end

    def program_name
      @parser.program_name
    end

    def banner=(banner)
      @parser.banner = banner
    end

    def parse(args)
      if args[0] =~ /^--/
        parser.parse(args)
      elsif args[0] == "help"
        if args.length == 1
          puts help_banner
        else
          help.parse(args[1..-1])
        end
      elsif command = commands.find { |c| c.display_name == args[0] }
        command.parse(args[1..-1])
      else
        puts help_banner
      end

      arguments
    end

    def help_banner
      help = ""
      help << parser.help
      help << "\n"
      help << " Commands:"
      help << "\n"
      commands.each do |command|
        help << "  #{command.name} #{command.desc}\n"
      end
      help << "\n"
      help << "Type '#{program_name} help COMMAND' for help with a specific command.\n"
      help
    end
  end

  class Command
    attr_reader :name, :desc, :parser, :arguments

    def initialize(name, desc)
      @name = name
      @desc = desc
      @parser = OptionParser.new
      @arguments = {}
    end

    def display_name
      name.to_s.tr("_", "-")
    end

    def banner
      parser.banner
    end

    def banner=(text)
      parser.banner = text
    end

    def flag(name, desc)
      add_option(Flag.new(name, desc))
    end

    def switch(name, desc)
      add_option(Switch.new(name, desc))
    end

    def add_option(option)
      option.configure(parser, arguments)
    end

    def help
      parser.help
    end

    def parse(*args)
      parser.parse(*args)
    end
  end

  class Help
    attr_reader :parser

    def initialize
      @parser = OptionParser.new
    end

    def register(command)
      parser.on("--#{command.display_name}") do
        puts command.help
        exit
      end
    end

    def parse(args)
      parser.parse("--#{args[0]}")
    end

    def to_s
      parser.help
    end
  end
end
