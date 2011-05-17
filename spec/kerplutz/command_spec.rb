require 'spec_helper'

module Kerplutz
  describe Command do
    subject { Command.new("test", "") }

    context "#add_option" do
      it "passes the parser into the option for configuration" do
        option = Option.new(:name, "Description")
        option.should_receive(:configure).with(subject.parser, subject.arguments)
        subject.add_option(option)
      end
    end
  end
end

