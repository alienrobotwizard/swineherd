module Swineherd
  class WukongScript < Script
    attr_accessor :input
    def initialize *args
      super(*args)
      @input = []
    end

    def cmd
      raise "No wukong input specified" if @input.empty?
      Wukong.cmd(script, @options, @input.join(','), output.join(','))
    end
  end
end
