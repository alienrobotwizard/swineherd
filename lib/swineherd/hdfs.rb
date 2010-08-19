module Swineherd

  #
  # Hadoop file classes, should use a better library if one exists
  #
  class Hfile
    #
    # Test if this file exists on the hdfs
    #
    def self.exist? target
      system %Q{hadoop fs -test -e #{target}}
    end

    #
    # Make a new hdfs dir, returns non-zero if already
    # exists
    #
    def self.mkdir target
      system %Q{hadoop fs -mkdir #{target}}
    end

    #
    # Removes hdfs file
    #
    def self.rmr target
      system %Q{hadoop fs -rmr #{target}}
    end

    #
    # Removes hdfs file
    #
    def self.rm target
      system %Q{hadoop fs -rm #{target}}
    end
    
  end
  
end
