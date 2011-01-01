module Swineherd

  #
  # Methods for dealing with hadoop distributed file system (hdfs)
  #
  class HDFS
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

    #
    # Moves hdfs file from source to dest
    #
    def self.mv source, dest
      system %Q{hadoop fs -mv #{source} #{dest}}
    end

    #
    # Distributed streaming from input to output
    #
    def self.stream input, output
     system("${HADOOP_HOME}/bin/hadoop \\
       jar         ${HADOOP_HOME}/contrib/streaming/hadoop-*streaming*.jar                     \\
       -D          mapred.job.name=\"Swineherd Stream (#{File.basename(input)} -> #{output})\" \\
       -D          mapred.min.split.size=1000000000                                            \\
       -D          mapred.reduce.tasks=0                                                       \\
       -mapper     \"/bin/cat\"                                                                \\
       -input      \"#{input}\"                                                                \\
       -output     \"#{output}\"")
    end

    #
    # Concatenates a hadoop dir into a local file
    #
    def self.cat_to_local src, dest
      if !File.exist?(dest)
        FileUtils.mkdir_p dest
        system %Q{hadoop fs -cat #{src}/\* > #{dest}} unless File.exist?(dest)
      end
    end

    #
    # Needs to return true if no outputs exist, false otherwise,
    # raise error if some do and some dont
    #
    def self.check_paths paths
      exist_count   = 0 # no outputs exist
      paths.each{|hdfs_path| exist_count += 1 if exist?(hdfs_path) }
      raise "Indeterminate output state" if (exist_count > 0) && (exist_count < paths.size)
      return true if exist_count == 0
      false
    end

  end

end
