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
    attr_reader :base

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
      command = Command.new(name, desc, base.arguments)
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
    attr_reader :top, :commands, :arguments

    extend Forwardable; def_delegators :@top, :add_option, :name, :banner=

    def initialize(name, arguments={})
      @arguments = arguments
      @top       = Command.new(name, '', @arguments)
      @commands  = CommandMap.new
    end

    def add_command(command)
      commands << command
    end

    def parse(args)
      first, *rest = args

      case first

      when help
        puts (rest.empty? ? banner : commands[rest.first].help)

      when option
        top.parse(args)

      when commands
        commands[first].parse(rest)

      else
        puts banner
      end

      arguments
    end

    def banner
      help = ""
      help << top.help << "\n"
      help << " Commands:\n" << commands.summary << "\n"
      help << "Type '#{name} help COMMAND' for help with a specific command.\n"
    end

    private

    def help
      /^(--help|help)$/
    end

    def option
      /^--/
    end
  end

  class Command
    attr_reader :name, :desc, :arguments, :parser

    extend Forwardable; def_delegators :@parser, :banner, :help, :parse

    def initialize(name, desc, arguments={})
      @name = name
      @desc = desc
      @arguments = arguments
      @parser = OptionParser.new
    end

    def display_name
      name.to_s.tr("_", "-")
    end

    def banner=(banner)
      parser.banner = (banner.chomp << "\n\n")
    end

    def add_option(option)
      option.configure(parser, arguments)
    end
  end

  class CommandMap
    attr_reader :commands

    def initialize
      @commands = {}
      @summary = ""
    end

    def add(command)
      commands[command.display_name] = command
    end

    def <<(command)
      add(command) and return self
    end

    def [](display_name)
      commands[display_name]
    end

    def ===(display_name)
      commands.has_key?(display_name)
    end

    def summary(indent=2)
      commands.inject("") do |acc, (display_name, command)|
        acc << " " * indent << "#{display_name} #{command.desc}\n"
      end
    end
  end
end
