module Swineherd
  class RScript < Script
    def cmd
      R.cmd(script)
    end
  end
end
