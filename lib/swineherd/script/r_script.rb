module Swineherd::Script
  class RScript
    include Common
    def cmd
      "/usr/bin/Rscript --vanilla #{script}"
    end
  end
end
