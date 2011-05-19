require 'optparse'
require 'forwardable'

module Kerplutz
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
end
