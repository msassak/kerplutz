require 'optparse'

module Kerplutz
  def self.configure
    config = yield Configuration.new
  end

  class Configuration
  end
end
