require 'spec_helper'

module Kerplutz
  describe Option do
    let(:parser) { OptionParser.new }
    subject { Option.new(:foo, "Do foo") }

    it "generates the parser arguments" do
      subject.parser_args.should == ["--foo", "Do foo"]
    end

    context "with an abbreviation" do
      it "generates the parser arguments" do
        subject.abbrev = :f
        subject.parser_args.should == ["-f", "--foo", "Do foo"]
        subject.abbrev = :option_parser_does_weird_things_if_more_than_one_character
        subject.parser_args.should == ["-o", "--foo", "Do foo"]
      end
    end
  end

  describe Flag do
    let(:parser) { OptionParser.new }
    let(:args) { Hash.new }

    context "with no arguments" do
      subject { Flag.new(:kuato, 'Summon Kuato') }

      its(:option_sig) { should == "--kuato" }

      it "configures the parser" do
        subject.configure(parser) do |value|
          value.should === true
        end
        parser.parse("--kuato")
      end
    end

    context "with an optional argument" do
      subject { Flag.new(:kuato, 'Summon Kuato', :host) }

      its(:option_sig) { should == "--kuato [HOST]" }

      it "configures the parser" do
        subject.configure(parser) do |value|
          value.should == "George"
        end
        parser.parse("--kuato", "George")

        subject.configure(parser) do |value|
          value.should === true
        end
        parser.parse("--kuato")
      end
    end

    context "with a required argument" do
      subject do
        flag = Flag.new(:kuato, 'Summon Kuato', :host)
        flag.arg_required = true
        flag
      end

      its(:option_sig) { should == "--kuato HOST" }

      it "configures the parser" do
        subject.configure(parser) { |value| } # no-op
        expect { parser.parse("--kuato") }.to raise_error(OptionParser::MissingArgument)

        subject.configure(parser) do |value|
          value.should == "George"
        end
        parser.parse("--kuato", "George")
      end
    end
  end

  describe Switch do
    let(:parser) { OptionParser.new }
    let(:args) { Hash.new }

    subject { Switch.new(:verbose, "Be chatty") }

    its(:option_sig) { should == "--[no-]verbose" }

    it "configures the parser" do
      subject.configure(parser) do |value|
        value.should === true
      end
      parser.parse("--verbose")

      subject.configure(parser) do |value|
        value.should be_false
      end
      parser.parse("--no-verbose")
    end
  end

  describe Action do
    let(:parser) { OptionParser.new }
    let(:args) { Hash.new }

    subject do
      action = Action.new(:start_reactor, "Start the reactor!") do
        $action = "Hello there"
      end
      action.continue_after_exec = true
      action
    end

    it "configures the parser" do
      subject.configure(parser)
      $action.should eq(nil)
      parser.parse("--start-reactor")
      $action.should eq("Hello there")
    end
  end
end
