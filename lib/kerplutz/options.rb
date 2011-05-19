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

    def option_sig
      "--#{display_name}"
    end

    def parser_arguments
      [option_sig, desc]
    end

    def configure(parser, arguments)
      raise "You'll need to implement this one yourself, bub."
    end
  end

  class Flag < Option
    attr_accessor :arg_name, :argument_required

    def initialize(name, desc, *args)
      super(name, desc)
      @args = args
      @arg_name = args[0]
    end

    def configure(parser, arguments)
      args = [option_sig, desc]
      args.unshift("-#{abbrev}") if abbrev

      parser.on(*args) do |arg|
        if NilClass === arg
          arguments[name] = true
        else
          arguments[name] = arg
        end
      end
    end

    def option_sig
      "#{super}#{formatted_arg_name}"
    end

    def formatted_arg_name
      if arg_name and argument_required
        " #{arg_name.to_s.upcase}"
      elsif arg_name
        " [#{arg_name.to_s.upcase}]"
      end
    end
  end

  class Switch < Option
    def option_sig
      "--[no-]#{display_name}"
    end

    def configure(parser, arguments)
      args = [option_sig, desc]
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

      args = [option_sig, desc]
      args.unshift("-#{abbrev}") if abbrev

      parser.on(*args, &wrapper)
    end
  end
end
