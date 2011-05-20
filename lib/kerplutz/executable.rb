require 'forwardable'

require 'kerplutz/command'
require 'kerplutz/command_map'

module Kerplutz
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
      #first, *rest = args

      #case first

      #when help
        #puts (rest.empty? ? banner : commands[rest.first].help)

      #when option
        #remainder = top.parse(args)

      #when commands
        #remainder = commands[first].parse(rest)

      #else
        #puts banner
      #end

      #[arguments, remainder || []]

      if cmd = args.find { |el| commands.has_command?(el) }
        cmd_idx = args.index(cmd)
        top_args, cmd_args = args.partition.with_index do |_arg, idx|
          idx < cmd_idx
        end
        top.parse(top_args)
        remainder = commands[cmd].parse(cmd_args[1..-1])
      else
        remainder = top.parse(args)
      end

      [arguments, remainder || []]
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
end
