module Swineherd
  class PigScript < Script
    def cmd
      Pig.cmd(@options[:pig_options], @options, script)
    end
  end
end
