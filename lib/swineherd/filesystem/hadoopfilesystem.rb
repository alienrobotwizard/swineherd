module Swineherd

  #
  # Methods for dealing with hadoop distributed file system (hdfs). This class
  # requires that you run with JRuby as it makes use of the native java hadoop
  # libraries.
  #
  class HadoopFileSystem

    include Swineherd::BaseFileSystem

    attr_accessor :conf, :hdfs

    #
    # Initialize a new hadoop file system, needs path to hadoop configuration
    #
    def initialize *args
      check_and_set_environment
      @conf = Java::org.apache.hadoop.conf.Configuration.new
      @hdfs = Java::org.apache.hadoop.fs.FileSystem.get(@conf)
    end

    #
    # Make sure environment is sane then set up environment for use
    #
    def check_and_set_environment
      check_env
      set_env
    end

    def rm path
      @hdfs.delete(Path.new(path), true)
    end

    def exists? path
      @hdfs.exists(Path.new(path))
    end

    def mv srcpath, dstpath
      @hdfs.rename(Path.new(srcpath), Path.new(dstpath))
    end

    def cp srcpath, dstpath
      FileUtil.copy(@hdfs, Path.new(srcpath), @hdfs, Path.new(dstpath), false, @conf)
    end

    def mkpath path
      @hdfs.mkdirs(Path.new(path))
    end

    #
    # Symlinks are not supported at the moment
    #
    def type path
      status = @hdfs.get_file_status(Path.new(path))
      return "file" unless status.is_dir
      "directory"
    end

    def entries dirpath
      list = @hdfs.list_status(Path.new(dirpath))
      list.map{|path| path.get_path.to_s}
    end

    def close *args
      @hdfs.close
    end

    # include Swineherd::BaseFileSystem::ClassMethods

    # #
    # # Test if this file exists on the hdfs
    # #
    # def self.exist? target
    #   system %Q{hadoop fs -test -e #{target}}
    # end
    #
    # #
    # # Make a new hdfs dir, returns non-zero if already
    # # exists
    # #
    # def self.mkdir target
    #   system %Q{hadoop fs -mkdir #{target}}
    # end
    #
    # #
    # # Make a new hdfs dir if and only if it does not already exist
    # #
    # def self.mkdir_p target
    #   mkdir target unless exist? target
    # end
    #
    # #
    # # Removes hdfs file
    # #
    # def self.rmr target
    #   system %Q{hadoop fs -rmr #{target}}
    # end
    #
    # #
    # # Get an array of paths in the targeted hdfs path
    # #
    # def self.dir_entries target
    #   stuff = `hadoop fs -ls #{target}`
    #   stuff = stuff.split(/\n/).map{|l| l.split(/\s+/).last}
    #   stuff[1..-1] rescue []
    # end
    #
    # #
    # # Removes hdfs file
    # #
    # def self.rm target
    #   system %Q{hadoop fs -rm #{target}}
    # end
    #
    # #
    # # Moves hdfs file from source to dest
    # #
    # def self.mv source, dest
    #   system %Q{hadoop fs -mv #{source} #{dest}}
    # end
    #
    # #
    # # Distributed streaming from input to output
    # #
    # def self.stream input, output
    #  system("${HADOOP_HOME}/bin/hadoop \\
    #    jar         ${HADOOP_HOME}/contrib/streaming/hadoop-*streaming*.jar                     \\
    #    -D          mapred.job.name=\"Swineherd Stream (#{File.basename(input)} -> #{output})\" \\
    #    -D          mapred.min.split.size=1000000000                                            \\
    #    -D          mapred.reduce.tasks=0                                                       \\
    #    -mapper     \"/bin/cat\"                                                                \\
    #    -input      \"#{input}\"                                                                \\
    #    -output     \"#{output}\"")
    # end
    #
    # #
    # # Given an array of input dirs, stream all into output dir and remove duplicate records.
    # # Reasonable default hadoop streaming options are chosen.
    # #
    # def self.merge inputs, output, options = {}
    #   options[:reduce_tasks]     ||= 25
    #   options[:partition_fields] ||= 2
    #   options[:sort_fields]      ||= 2
    #   options[:field_separator]  ||= '/t'
    #   names = inputs.map{|inp| File.basename(inp)}.join(',')
    #   cmd   = "${HADOOP_HOME}/bin/hadoop \\
    #    jar         ${HADOOP_HOME}/contrib/streaming/hadoop-*streaming*.jar                   \\
    #    -D          mapred.job.name=\"Swineherd Merge (#{names} -> #{output})\"               \\
    #    -D          num.key.fields.for.partition=\"#{options[:partition_fields]}\"            \\
    #    -D          stream.num.map.output.key.fields=\"#{options[:sort_fields]}\"             \\
    #    -D          mapred.text.key.partitioner.options=\"-k1,#{options[:partition_fields]}\" \\
    #    -D          stream.map.output.field.separator=\"'#{options[:field_separator]}'\"      \\
    #    -D          mapred.min.split.size=1000000000                                          \\
    #    -D          mapred.reduce.tasks=#{options[:reduce_tasks]}                             \\
    #    -partitioner org.apache.hadoop.mapred.lib.KeyFieldBasedPartitioner                    \\
    #    -mapper     \"/bin/cat\"                                                              \\
    #    -reducer    \"/usr/bin/uniq\"                                                         \\
    #    -input      \"#{inputs.join(',')}\"                                                   \\
    #    -output     \"#{output}\""
    #   puts cmd
    #   system cmd
    # end
    #
    # #
    # # Concatenates a hadoop dir or file into a local file
    # #
    # def self.cat_to_local src, dest
    #   system %Q{hadoop fs -cat #{src}/[^_]* > #{dest}} unless File.exist?(dest)
    # end
    #
    # #
    # # Needs to return true if no outputs exist, false otherwise,
    # # raise error if some do and some dont
    # #
    # def self.check_paths paths
    #   exist_count   = 0 # no outputs exist
    #   paths.each{|hdfs_path| exist_count += 1 if exist?(hdfs_path) }
    #   raise "Indeterminate output state" if (exist_count > 0) && (exist_count < paths.size)
    #   return true if exist_count == 0
    #   false
    # end


    #
    # Check that we are running with jruby, check for hadoop home. hadoop_home
    # is preferentially set to the HADOOP_HOME environment variable if it's set,
    # '/usr/local/share/hadoop' if HADOOP_HOME isn't defined, and
    # '/usr/lib/hadoop' if '/usr/local/share/hadoop' doesn't exist. If all else
    # fails inform the user that HADOOP_HOME really should be set.
    #
    def check_env
      begin
        require 'java'
      rescue LoadError => e
        raise "\nJava not found, are you sure you're running with JRuby?\n" + e.message
      end
      @hadoop_home = (ENV['HADOOP_HOME'] || '/usr/local/share/hadoop')
      @hadoop_home = '/usr/lib/hadoop' unless File.exist? @hadoop_home
      raise "\nHadoop installation not found, try setting HADOOP_HOME\n" unless File.exist? @hadoop_home
    end

    #
    # Place hadoop jars in class path, require appropriate jars, set hadoop conf
    #
    def set_env
      require 'java'
      @hadoop_conf = (ENV['HADOOP_CONF_DIR'] || File.join(@hadoop_home, 'conf'))
      $CLASSPATH << @hadoop_conf
      Dir["#{@hadoop_home}/hadoop*.jar", "#{@hadoop_home}/lib/*.jar"].each{|jar| require jar}

      java_import 'org.apache.hadoop.conf.Configuration'
      java_import 'org.apache.hadoop.fs.Path'
      java_import 'org.apache.hadoop.fs.FileSystem'
      java_import 'org.apache.hadoop.fs.FileUtil'
      java_import 'org.apache.hadoop.mapreduce.lib.input.FileInputFormat'
      java_import 'org.apache.hadoop.mapreduce.lib.output.FileOutputFormat'

    end

  end

end
