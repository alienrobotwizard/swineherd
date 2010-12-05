module Swineherd
  class LocalFS
    def self.check_paths paths
      exist_count   = 0 # no outputs exist
      paths.each{|path| exist_count += 1 if File.exist?(path) }
      raise "Indeterminate output state" if (exist_count > 0) && (exist_count < paths.size)
      return true if exist_count == 0
      false
    end
  end
end
