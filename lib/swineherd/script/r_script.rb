module Swineherd::Script
  class RScript
    include Common

    def local_cmd
      "/usr/bin/Rscript --vanilla #{script}"
    end

    def cmd
      local_cmd
    end

  end
end
