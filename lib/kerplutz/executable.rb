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

    # TODO: Extract this method into separate class that gives all 
    # the involved parties the chance to parse all of the args
    def parse(args)
      if args[0] =~ /^(--help|help)$/
        first, *rest = args
        if rest.empty?
          puts banner
        else
          puts commands[rest.first].help
        end
      elsif cmd = args.find { |el| commands.has_command?(el) }
        cmd_idx = args.index(cmd)
        top_args, cmd_args = args.partition.with_index do |_arg, idx|
          idx < cmd_idx
        end
        top.parse(top_args)
        remainder = commands[cmd].parse(cmd_args[1..-1])
      else
        if args.empty?
          puts banner
        else
          remainder = top.parse(args)
        end
      end

      [arguments, remainder || []]
    end

    def banner
      help = ""
      help << top.help << "\n"
      help << " Commands:\n" << commands.summary << "\n"
      help << "Type '#{name} help COMMAND' for help with a specific command.\n"
    end
  end
end
