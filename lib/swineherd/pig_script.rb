module Swineherd
  class PigScript < Script
    attr_accessor :pig_options
    def cmd
      Pig.cmd(@pig_options, @options, script)
    end
  end
end
