require 'spec_helper'

module Kerplutz
  describe Flag do
    let(:parser) { OptionParser.new }
    let(:args) { Hash.new }

    context "with no arguments" do
      subject { Flag.new(:kuato, 'Summon Kuato') }

      it "generates the parser signature" do
        parser.should_receive(:on).with("--kuato", "Summon Kuato")
        subject.configure(parser, {})
      end

      it "configures the parser" do
        subject.configure(parser, args)
        parser.parse("--kuato")
        args[:kuato].should be_true
      end
    end

    context "with an optional argument" do
      subject { Flag.new(:kuato, 'Summon Kuato', :host) }

      it "generates the parser signature" do
        parser.should_receive(:on).with("--kuato [HOST]", "Summon Kuato")
        subject.configure(parser, {})
      end

      it "configures the parser" do
        subject.configure(parser, args)

        parser.parse("--kuato", "George")
        args[:kuato].should == "George"

        parser.parse("--kuato")
        args[:kuato].should == true
      end
    end

    context "with a required argument" do
      subject do
        flag = Flag.new(:kuato, 'Summon Kuato', :host)
        flag.argument_required = true
        flag
      end

      it "generates the parser signature" do
        parser.should_receive(:on).with("--kuato HOST", "Summon Kuato")
        subject.configure(parser, {})
      end

      it "configures the parser" do
        subject.configure(parser, args)
        expect { parser.parse("--kuato") }.to raise_error(OptionParser::MissingArgument)
        args[:kuato].should be_nil

        parser.parse("--kuato", "George")
        args[:kuato].should == "George"
      end
    end
  end

  describe Switch do
    let(:parser) { OptionParser.new }
    let(:args) { Hash.new }

    subject { Switch.new(:verbose, "Be chatty") }

    it "generates the parser signature" do
      parser.should_receive(:on).with("--[no-]verbose", "Be chatty")
      subject.configure(parser, {})
    end

    it "configures the parser" do
      subject.configure(parser, args)

      parser.parse("--verbose")
      args[:verbose].should be_true

      parser.parse("--no-verbose")
      args[:verbose].should be_false
    end
  end

  describe Action do
    it "generates the parser signature"
    it "configures the parser"
  end
end
