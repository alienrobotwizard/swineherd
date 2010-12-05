module Swineherd
  class R
    def self.cmd(script)
      "/usr/bin/Rscript --vanilla #{script}"
    end
  end
end
