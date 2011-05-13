require 'spec_helper'

module Kerplutz
  describe Executable do
    subject { Executable.new }

    context "#add_option" do
      it "passes the parser into the option for configuration" do
        option = Option.new(:name, "Description")
        option.should_receive(:configure).with(subject.parser, subject.arguments)
        subject.add_option(option)
      end
    end

    context "#parse" do
      it "extracts the options from the arguments" do
        subject.add_option(Switch.new(:foo, ''))
        arguments = subject.parse(["--foo"])
        arguments.should == { :foo => true }
      end
    end
  end
end
