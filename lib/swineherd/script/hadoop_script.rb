module Swineherd::Script

  #
  # native Java map-reduce
  #
  class HadoopScript
    include Common
    attr_accessor :main_class, :run_jar, :java_options, :hadoop_classpath, :libjars

    def initialize *args
      super(*args)
      @options = Hash.new{|h,k| h[k] = {}} # need to support nested options for this
    end

    #
    # Generic hash {:foo => 'bar'} to '-Dfoo=bar' but more commonly
    # is a nested hash eg.
    # {:cassandra => {:config => 'cassandra.yaml'}} will transform to
    # '-Dcassandra.config=cassandra.yaml'
    #
    def java_args options

    end
    
    def cmd
      [
        "HADOOP_CLASSPATH=#{hadoop_classpath}",
        "#{hadoop_home}/bin/hadoop jar #{run_jar}",
        main_class,
        java_args(options),
        "-libjars #{libjars}",
        "#{input.join(',')}",
        "#{output.join(',')}"
      ].flatten.compact.join(" \t\\\n  ")
    end

  end
end
