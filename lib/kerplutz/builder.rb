require 'kerplutz/executable'
require 'kerplutz/options'

module Kerplutz
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
end
