module Swineherd
  class Workflow
    attr_accessor :workdir, :outputs, :output_counts
    
    #
    # Create a new workflow and new namespace for this workflow
    #
    def initialize flow_id, &blk
      @flow_id = flow_id
      @output_counts = Hash.new{|h,k| h[k] = 0}
      @outputs       = Hash.new{|h,k| h[k] = []}
      namespace @flow_id do
        self.instance_eval(&blk)
      end
    end

    #
    # Get next logical output of taskname by incrementing internal counter
    #
    def next_output taskname
      raise "No working directory specified." unless @workdir
      @outputs[taskname] << "#{@workdir}/#{@flow_id}/#{taskname}-#{@output_counts[taskname]}"
      @output_counts[taskname] += 1
      latest_output(taskname)
    end

    #
    # Get latest output of taskname
    #
    def latest_output taskname
      @outputs[taskname].last
    end

    #
    # Runs workflow starting with taskname
    #
    def run taskname
      Log.info "Launching workflow task #{@flow_id}:#{taskname} ..."
      Rake::Task["#{@flow_id}:#{taskname}"].invoke
      Log.info "Workflow task #{@flow_id}:#{taskname} finished"
    end

    #
    # Describes the dependency tree of all tasks belonging to self
    #
    def describe
      Rake::Task.tasks.each do |t|
        Log.info("Task: #{t.name} [#{t.inspect}]") if t.name =~ /#{@flow_id}/
      end
    end

  end
end
