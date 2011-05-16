require 'spec_helper'

module Kerplutz
  describe Flag do
    let(:parser) { double("parser") }

    it "configures the parser with no arguments" do
      parser.should_receive(:on).with("--kuato", "Summon Kuato")
      f = Flag.new(:kuato, 'Summon Kuato')
      f.configure(parser, {})
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
