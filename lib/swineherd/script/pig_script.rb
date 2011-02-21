module Swineherd::Script
  class PigScript
    include Common

    #
    # Convert a generic hash of options {:foo => 'bar'} into
    # command line options for pig '-p FOO=bar'
    #
    def pig_args options
      options.map{|opt,val| "-p #{opt.to_s.upcase}=#{val}" }.join(' ')
    end

    def local_cmd
      "pig -x local #{pig_args(@options)} #{script}"
    end

    def cmd
      "pig #{pig_args(@options)} #{script}"
    end

  end
end
