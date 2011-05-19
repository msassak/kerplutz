require 'kerplutz/executable'
require 'kerplutz/builder'

module Kerplutz
  class << self
    def build(name)
      executable = Executable.new(name)
      yield builder = Builder.new(executable)
      builder.result
    end
  end
end
