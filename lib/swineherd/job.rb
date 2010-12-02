# TODO:
#
# - ability to run locally
# - dry run
# - r scripts
# - bash scripts
# - create dependency graph
#



# When type == 'pig'
# required:
# name, parameters, script, pig_output_parameters
#
# When type == 'wukong'
# require:
# name, script, input, output
module Swineherd

  #
  # Job class is at its core a rake task
  #
  class Job

    #
    # Initialize job, fill variables, and create rake task
    #
    def initialize job_id, &blk
      @job_id       = job_id
      @name         = ''
      @type         = ''
      @dependencies = []
      @script       = ''
      @output       = ''
      @parameters   = {}
      @attributes   = {}
      @input        = ''
      @pig_opts     = ''
      @pig_output   = ''
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
    # In pig you specify all variables with -p. Thus, specifying
    # output(s) in pig is very flexible and difficult to validate.
    # To get around this there will be a required 'pig_output'
    # variable that is nothing more than a comma separated list of
    # keys in the 'parameters' hash to use as outputs.
    #
    def pig_output pig_output = nil
      return @pig_output unless pig_output
      @pig_output = pig_output
    end

    #
    # Sets up dependencies with rake
    #
    def handle_dependencies
      return if dependencies.empty?
      task name => dependencies
    end

    #
    # Need to set parameters[pig_output] = parameters[pig_output]/job_id
    #
    def set_pig_outputs!
      @pig_outputs = pig_output.split(',').map do |param|
        unique_output             = File.join(parameters[param.to_sym], @job_id)
        parameters[param.to_sym] = unique_output
        unique_output
      end
    end

    #
    # Need to set 'output1,output2,..' to 'output1/job_id,output2/job_id,...'
    #
    def set_wukong_outputs!
      @wukong_outputs = output.split(',').map!{|path| File.join(path, @job_id)}
    end

    def check_outputs
      case type
      when 'pig' then
        HDFS.check_paths(@pig_outputs)
      when 'wukong' then
        HDFS.check_paths(@wukong_outputs)
      end
    end

    #
    # Every job is compiled into a single command for command line and thus
    # can be invoked independent of everything else
    #
    def cmd
      case type
      when 'pig' then
        raise "You must specify pig_output when running pig scripts." if pig_output.empty?
        set_pig_outputs!
        return Pig.cmd(pig_opts, parameters, script)
      when 'wukong' then
        raise "No inputs specified"        if input.empty?
        raise "You must specify an output" if output.empty?
        set_wukong_outputs!
        return Wukong.cmd(script, parameters, input, @wukong_outputs.join(','))
      end
    end

    #
    # Every job is compiled into a rake task
    #
    def raketask
      task name do
        puts cmd if Settings.verbose
        system "#{cmd}" if check_outputs
      end
    end
  end
end
