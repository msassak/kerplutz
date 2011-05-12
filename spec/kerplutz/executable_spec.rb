require 'spec_helper'

module Kerplutz
  describe Executable do
    subject { Executable.new }

    context "#add_option" do
      it "passes the parser into the option for configuration" do
        option = Option.new(:name, "Description")
        option.should_receive(:configure).with(subject.parser)
        subject.add_option(option)
      end
    end
  end
end
