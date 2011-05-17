require 'spec_helper'

module Kerplutz
  describe Flag do
    let(:parser) { OptionParser.new }
    let(:args) { Hash.new }

    context "with no arguments" do
      subject { Flag.new(:kuato, 'Summon Kuato') }

      it "configures the parser" do
        parser.should_receive(:on).with("--kuato", "Summon Kuato")
        subject.configure(parser, {})
      end

      it "extracts arguments correctly" do
        subject.configure(parser, args)
        parser.parse("--kuato")
        args[:kuato].should be_true
      end
    end

    it "configures the parser with an optional argument" do
      parser.should_receive(:on).with("--kuato [HOST]", "Summon Kuato")
      f = Flag.new(:kuato, 'Summon Kuato', :host)
      f.configure(parser, {})
    end

    it "configures the parser with a required argument" do
      parser.should_receive(:on).with("--kuato HOST", "Summon Kuato")
      f = Flag.new(:kuato, 'Summon Kuato', :host)
      f.argument_required = true
      f.configure(parser, {})
    end
  end

  describe Switch do
    it "configures the parser correctly"
  end

  describe Action do
    it "configures the parser correctly"
  end
end
