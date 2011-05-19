module Kerplutz
  class Option
    attr_reader   :name, :desc
    attr_accessor :abbrev

    def self.build(name, desc, opts)
      option = self.new(name, desc)
      option.abbrev = opts[:abbrev]
      option
    end

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

    def abbrev_sig
      return "-#{abbrev[0]}" if abbrev
    end

    def parser_args
      [abbrev_sig, option_sig, desc].compact
    end

    def configure(parser, arguments)
      raise "You'll need to implement this one yourself, bub."
    end
  end

  class Flag < Option
    attr_accessor :arg_name, :arg_required

    def self.build(name, desc, opts)
      flag = super(name, desc, opts)
      flag.arg_name = opts[:required] || opts[:optional]
      flag.arg_required = opts.has_key?(:required)
      flag
    end

    def initialize(name, desc, arg_name=nil)
      super(name, desc)
      @arg_name = arg_name
    end

    def configure(parser, arguments)
      parser.on(*parser_args) do |arg|
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

    private

    def formatted_arg_name
      if arg_name and arg_required
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
      parser.on(*parser_args) do |arg|
        arguments[name] = arg
      end
    end
  end

  class Action < Option
    attr_accessor :action, :continue_after_exec

    def self.build(name, desc, opts, &action)
      new_action = super(name, desc, opts)
      new_action.action = action
      new_action
    end

    def initialize(name, desc, &action)
      super(name, desc)
      @action = action
    end

    def configure(parser, arguments)
      parser.on(*parser_args) do
        action.call
        exit unless continue_after_exec
      end
    end
  end
end
