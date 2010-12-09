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
    # Converts an arbitrarily nested hash to flattened arguments
    # for passing to java program. For example:
    #
    # {:mapred => {:reduce => {:tasks => 0}}}
    #
    # will transform to:
    #
    # '-Dmapred.reduce.tasks=0'
    #
    def java_args args
      to_dotted_args(args).map{|arg| "-D#{arg}"}
    end

    #
    # Uses recursion to take an arbitrarily nested hash and
    # flatten it into dotted args. See 'to_java_args'. Can
    # you do it any better?
    #
    def to_dotted_args args
      args.map do |k,v|
        if v.is_a?(Hash)
          to_dotted_args(v).map do |s|
            [k,s].join(".")
          end
        else
          "#{k}=#{v}"
        end
      end.flatten
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
