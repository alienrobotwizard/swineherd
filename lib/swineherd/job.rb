module Swineherd

  #
  # Job class is at its core a rake task
  #
  class Job

    #
    # Initialize job, fill variables, and create rake task
    #
    def initialize &blk
      @name         = ''
      @type         = ''
      @dependencies = []
      @script       = ''
      @output       = ''
      @parameters   = {}
      @attributes   = {}
      @input        = ''
      @pig_opts     = ''
      self.instance_eval(&blk)
      raketask
      handle_dependencies
    end

    #
    # Will be the name of the rake task
    #
    def name name = nil
      return @name unless name
      @name = name
    end

    #
    # Type of job to create (pig, wukong, r)
    #
    def type type = nil
      return @type unless type
      @type = type
    end

    #
    # An array of job names as dependencies
    #
    def dependencies dependencies = nil
      return @dependencies unless dependencies
      @dependencies = dependencies
    end

    #
    # Script that actually runs, always treated as a template
    #
    def script script = nil
      return @script unless script
      @script = Template.new(script, attributes).substitute!
    end

    #
    # A comma separated list of output paths
    #
    def output output = nil
      return @output unless output
      @output = output
    end

    #
    # Hash of command line parameters to pass script before it is ran
    #
    def parameters parameters = nil
      return @parameters unless parameters
      @parameters = parameters
    end

    #
    # Hash of parameters to substitute in the case that script is actually a template
    #
    def attributes attributes = nil
      return @attributes unless attributes
      @attributes = attributes
    end

    #
    # Comma separated list of inputs for wukong
    #
    def input input = nil
      return @input unless input
      @input = input
    end

    #
    # Additional java options (-D) for Pig
    #
    def pig_opts pig_opts = nil
      return @pig_opts unless pig_opts
      @pig_opts = pig_opts
    end

    #
    # Sets up dependencies with rake
    #
    def handle_dependencies
      return if dependencies.empty?
      task name => dependencies
    end

    #
    # Every job is compiled into a single command for command line and thus
    # can be invoked independent of everything else
    #
    def cmd
      case type
      when 'pig' then
        return Pig.cmd(pig_opts, parameters, script)
      when 'wukong' then
        raise "No inputs specified" if input.empty?
        return Wukong.cmd(script, parameters, input, output)
      end
    end

    #
    # Every job is compiled into a rake task
    #
    def raketask
      task name do
        puts cmd if Settings.verbose
        system "#{cmd}"
      end
    end
  end
end
