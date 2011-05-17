require 'optparse'
require 'forwardable'

module Kerplutz
  class << self
    def build(name)
      executable = Executable.new(name)
      yield builder = Builder.new(executable)
      builder.result
    end
  end

  class Builder
    attr_reader   :base

    def initialize(base)
      @base = base
    end

    def name
      base.name
    end

    def banner=(banner)
      base.banner = banner
    end

    def flag(name, desc="", opts={})
      base.add_option(Flag.new(name, desc))
    end

    def switch(name, desc="", opts={})
      base.add_option(Switch.new(name, desc))
    end

    def action(name, desc="", opts={}, &action)
      base.add_option(Action.new(name, desc, &action))
    end

    def command(name, desc="")
      command = Command.new(name, desc)
      yield builder = Builder.new(command)
      base.add_command(builder.result)
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

    def display_name
      name.to_s.tr("_", "-")
    end

    def configure(parser, arguments)
      raise "You'll need to implement this one yourself, bub."
    end
  end

  class Flag < Option
    attr_accessor :argument_required

    def initialize(name, desc, *args)
      super(name, desc)
      @args = args
    end

    def configure(parser, arguments)
      template = @args.inject("--#{display_name}") do |acc, arg|
        acc << " " << convert(arg)
      end

      parser.on(template, desc)
    end

    def convert(arg)
      argument_required ? arg.to_s.upcase : "[#{arg.to_s.upcase}]"
    end
  end

  class Switch < Option
    def configure(parser, arguments)
      parser.on("--[no-]#{display_name}", desc) do |arg|
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
      parser.on("--#{display_name}", desc, &@action)
    end
  end

  class Executable
    extend Forwardable
    attr_reader :commands, :arguments, :help
    def_delegators :@base_command, :add_option, :name, :banner=

    def initialize(name, arguments={})
      @arguments = arguments
      @base_command = Command.new(name, '', @arguments)
      @help = Help.new
      @commands = []
    end

    def add_command(command)
      help.register(command)
      commands << command
    end

    # Yuck
    def parse(args)
      if args[0] =~ /^--/
        @base_command.parse(args)

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
      help << @base_command.help
      help << "\n"
      help << " Commands:"
      help << "\n"
      commands.each do |command|
        help << "  #{command.name} #{command.desc}\n"
      end
      help << "\n"
      help << "Type '#{name} help COMMAND' for help with a specific command.\n"
      help
    end
  end

  class Command
    attr_reader :name, :desc, :parser, :arguments

    def initialize(name, desc, arguments={})
      @name = name
      @desc = desc
      @arguments = arguments
      @parser = OptionParser.new
    end

    def display_name
      name.to_s.tr("_", "-")
    end

    def banner
      parser.banner
    end

    def banner=(banner)
      parser.banner = (banner.chomp << "\n\n")
    end

    def add_option(option)
      option.configure(parser, arguments)
    end

    def help
      parser.help
    end

    def parse(args)
      parser.parse(args)
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
      munged = ["--#{args[0]}", *args[1..-1]]
      parser.parse(munged)
    end
  end
end
