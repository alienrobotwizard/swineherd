module Swineherd::Script
  class PigScript
    include Common
    attr_accessor :pig_options, :pig_classpath

    #
    # Convert a generic hash of options {:foo => 'bar'} into
    # command line options for pig '-p FOO=bar'
    #
    def pig_args options
      options.map{|opt,val| "-p #{opt.to_s.upcase}=#{val}" }.join(' ')
    end

    def cmd
      "PIG_CLASSPATH=#{@pig_classpath} PIG_OPTS='#{@pig_options}' pig #{pig_args(@options)} #{script}"
    end

  end
end
