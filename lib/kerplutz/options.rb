module Kerplutz
  class Option
    attr_reader :name, :desc
    attr_accessor :abbrev

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
      # TODO: refactor template generation
      template = @args.inject("--#{display_name}") do |acc, arg|
        acc << " " << convert(arg)
      end

      args = [template, desc]
      args.unshift("-#{abbrev}") if abbrev

      parser.on(*args) do |arg|
        if NilClass === arg
          arguments[name] = true
        else
          arguments[name] = arg
        end
      end
    end

    def convert(arg)
      argument_required ? arg.to_s.upcase : "[#{arg.to_s.upcase}]"
    end
  end

  class Switch < Option
    def configure(parser, arguments)
      args = ["--[no-]#{display_name}", desc]
      args.unshift("-#{abbrev}") if abbrev

      parser.on(*args) do |arg|
        arguments[name] = arg
      end
    end
  end

  class Action < Option
    attr_accessor :continue_after_exec

    def initialize(name, desc, &action)
      super(name, desc)
      @action = action
    end

    def configure(parser, arguments)
      wrapper = Proc.new do
        @action.call
        exit unless continue_after_exec
      end

      args = ["--#{display_name}", desc]
      args.unshift("-#{abbrev}") if abbrev

      parser.on(*args, &wrapper)
    end
  end
end
