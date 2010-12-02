module Swineherd
  class Pig
    #
    # Convert a generic hash of options {:foo => 'bar'} into
    # command line options for pig '-p FOO=bar'
    #
    def self.pig_args options
      options.map{|opt,val| "-p #{opt.to_s.upcase}=#{val}" }.join(' ')
    end

    def self.cmd(opts, args, script)
      "PIG_OPTS='#{opts}' pig #{self.pig_args(args)} #{script}"
    end

  end
end
