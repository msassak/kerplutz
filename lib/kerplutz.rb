require 'optparse'
require 'forwardable'

require 'kerplutz/options'

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

    def flag(name, desc, opts={})
      base.add_option(Flag.build(name, desc, opts))
    end

    def switch(name, desc, opts={})
      base.add_option(Switch.build(name, desc, opts))
    end

    def action(name, desc, opts={}, &action)
      base.add_option(Action.build(name, desc, opts, &action))
    end

    def command(name, desc)
      command = Command.new(name, desc, base.arguments)
      yield builder = Builder.new(command)
      base.add_command(builder.result)
    end

    def result
      base
    end
  end

  class Executable
    attr_reader :top, :commands, :arguments

    extend Forwardable; def_delegators :@top, :name, :banner, :banner=

    def initialize(name, arguments={})
      @arguments = arguments
      @top       = Command.new(name, '', @arguments)
      @commands  = CommandMap.new
    end

    def add_command(command)
      commands << command
    end

    def add_option(option)
      top.add_option(option, false)
    end

    def parse(args)
      first, *rest = args
      remainder = []

      case first

      when help
        puts (rest.empty? ? banner : commands[rest.first].help)

      when option
        remainder = top.parse(args)

      when commands
        remainder = commands[first].parse(rest)

      else
        puts banner
      end

      [arguments, remainder]
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
      /^(--|-)[\w-]+$/
    end
  end

  class Command
    attr_reader :name, :desc, :arguments, :parser

    extend Forwardable; def_delegators :@parser, :banner, :help, :parse

    def initialize(name, desc, arguments={})
      @name      = name
      @desc      = desc
      @arguments = arguments
      @parser    = OptionParser.new(default_banner)
    end

    def display_name
      @display_name ||= name.to_s.tr("_", "-")
    end

    def banner=(banner)
      parser.banner = (banner.chomp << "\n\n")
    end

    def add_option(option, prefix_key=true)
      if prefix_key
        key = :"#{name}_#{option.name}"
      else
        key = option.name.to_sym
      end

      option.configure(parser) do |value|
        arguments[key] = value
      end
    end

    private

    # TODO: Is this a better fit for Executable?
    def default_banner
      "Usage: #{command_name} [OPTIONS]\n\n"
    end

    def command_name
      if program_name == display_name
        program_name
      else
        "#{program_name} #{display_name}"
      end
    end

    def program_name
      @program_name ||= File.basename($PROGRAM_NAME)
    end
  end

  class CommandMap
    attr_reader :commands

    def initialize
      @commands = {}
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
