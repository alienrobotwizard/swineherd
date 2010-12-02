require 'rubygems'
require 'wukong'
require 'swineherd' ; include Swineherd

#
# - A workflow has a name and id
# - A workflow has many jobs
# - A workflow can describe jobs by name
# - A workflow can describe full dependency graph as a visualization
# - A job has a name
# - A job has dependencies
# - A job can describe how to run itself
# - A job has a type (pig, wukong, r)
# - A job has a script that is ALWAYS treated as an erb template
# - A job has command line parameters
# - A job has (optional) template parameters
# - A job is idempotent
#

Settings.define :flow_id, :env_var => 'SWINEHERD_FLOW_ID'
Settings.resolve!
options = Settings.dup


module Swineherd
  class WorkFlow
    attr_accessor :flow_id, :jobs
    def initialize(flow_id, &blk)
      @flow_id = flow_id
      @jobs    = {}
      yield @jobs
    end
  end

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

  class Pig
    
    #
    # Needs to return true if no outputs exist, false otherwise,
    # raise error if some do and some dont
    #
    def self.check_outputs outputs
      Hfile.check_paths(outputs.values)
    end

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

# optional

# pig_opts         '-Dmapred.reduce.tasks=100'
# parameters       {:somedata => '/path/to/somedata'}
# attributes       {:schema => 'blargh:chararray', :foo => 'bar'}

flow = Swineherd::WorkFlow.new(options.flow_id) do |jobs|

  myjob = Job.new do
    type             'pig'
    name             :myjob
    dependencies     [:other_task, :yet_another_task]
    script           'dumb_pig_script.pig'
    output           'out1,out2'
  end
  jobs[myjob.name] = myjob
  
end

p flow.jobs[:myjob].cmd
