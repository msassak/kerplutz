require 'spec_helper'

module Kerplutz
  describe Executable do
    let(:option) { Flag.new(:foo, '', :bar) }
    let(:command) { Command.new(:foo, '') }

    subject do
      exec = Executable.new("test")
      exec.add_option(option)
      exec.add_command(command)
      exec
    end

    describe "#parse" do
      it "extracts the options from the arguments" do
        subject.parse(["--foo"]).should == [{ :foo => true }, []]
        subject.parse(["--foo", "bar"]).should == [{ :foo => "bar" }, []]
      end

      it "parses an unambiguous flag argument" do
        subject.top.should_receive(:parse).with(["--foo", "bar"])
        subject.parse(["--foo", "bar"])
      end

      it "parses an ambiguous flag argument" do
        subject.top.should_receive(:parse).with(["--foo"])
        command.should_receive(:parse).with([])
        subject.parse(["--foo", "foo"])

        subject.top.should_receive(:parse).with(["--foo"])
        command.should_receive(:parse).with(["-x"])
        subject.parse(["--foo", "foo", "-x"])

        subject.top.should_receive(:parse).with(["--foo"])
        command.should_receive(:parse).with(["foo", "-x"])
        subject.parse(["--foo", "foo", "foo", "-x"])
      end
    end

    describe "#banner" do
      it "has a sensible default" do
        subject.banner.should =~ /^Usage: rspec test \[OPTIONS\]$/
      end
    end
  end
end
