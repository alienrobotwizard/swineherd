module Swineherd
  class Job
    def initialize &blk
      @name         = ''
      @type         = ''
      @dependencies = []
      @script       = ''
      @output       = ''
      @parameters   = {}
      @pig_opts     = ''
      self.instance_eval(&blk)
    end

    def name name = nil
      return @name unless name
      @name = name
    end

    def type type = nil
      return @type unless type
      @type = type
    end

    def dependencies dependencies = nil
      return @dependencies unless dependencies
      @dependencies = dependencies
    end

    def script script = nil
      return @script unless script
      @script = script
    end

    def output output = nil
      return @output unless output
      @output = output
    end

    def parameters parameters = nil
      return @parameters unless parameters
      @parameters = parameters
    end

    def pig_opts pig_opts = nil
      return @pig_opts unless pig_opts
      @pig_opts = pig_opts
    end

    #
    # Every job is compiled into a single command for command line and thus
    # can be invoked independent of everything else
    #
    def cmd
      case type
      when 'pig' then
        return Pig.cmd(pig_opts, parameters, script)
      end
    end

    #
    # Every job is compiled into a rake task
    #
    def raketask
      task name do
        system "#{cmd}"
      end
    end
  end
end
