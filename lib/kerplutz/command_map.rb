module Kerplutz
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

    def has_command?(display_name)
      self.===(display_name)
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
