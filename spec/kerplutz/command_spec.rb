require 'spec_helper'

module Kerplutz
  describe Command do
    let(:option) { Flag.new(:name, "Description") }
    let(:args) { Hash.new }
    subject { Command.new("commandy", "", args) }

    context "#add_option" do
      it "passes the parser into the option for configuration" do
        option.should_receive(:configure).with(subject.parser)
        subject.add_option(option)
      end
    end

    context "#parse" do
      it "adds the parsed argument into the arguments hash" do
        subject.add_option(option)
        subject.parse("--name")
        args.should have_key(:commandy_name)
        args[:commandy_name].should eq(true)
      end
    end
  end
end

