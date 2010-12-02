module Swineherd
  class Pig
    #
    # Convert a generic hash of options {:foo => 'bar'} into
    # command line options for pig '-p FOO=bar'
    #
    def self.pig_args options
      args = []
      options.each do |opt, val|
        args << ['-p', "#{opt.to_s.upcase}=#{val}"]
      end
      args.flatten.join(' ')
    end

    def self.cmd(opts, args, script)
      "PIG_OPTS='#{opts}' pig #{self.pig_args(args)} #{script}"
    end

  end
end
