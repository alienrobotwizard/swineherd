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
      @dependencies = []
      @script       = ''
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

    def script script = nil
      return @script unless script
      @script = script
    end

    #
    # An array of job names as dependencies
    #
    def dependencies dependencies = nil
      return @dependencies unless dependencies
      @dependencies = dependencies
    end

    def handle_dependencies
      return if dependencies.empty?
      task name => dependencies
    end

    def cmd
      @script.cmd
    end

    #
    # Every job is compiled into a rake task
    #
    def raketask
      task name do
        @script.run
      end
    end
  end
end
