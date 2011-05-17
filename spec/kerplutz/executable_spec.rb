require 'spec_helper'

module Kerplutz
  describe Executable do
    subject { Executable.new("test") }

    context "#parse" do
      it "extracts the options from the arguments" do
        subject.add_option(Switch.new(:foo, ''))
        arguments = subject.parse(["--foo"])
        arguments.should == { :foo => true }
      end
    end
  end
end
