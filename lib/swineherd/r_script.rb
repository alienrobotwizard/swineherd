module Swineherd
  class RScript < Script
    def cmd
      R.cmd(script)
    end

    #
    # Hacking this in for now since R operates locally
    #
    def run
      puts cmd
      system "#{cmd}"
    end

  end
end
