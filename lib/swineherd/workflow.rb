module Swineherd
  class Workflow
    attr_accessor :workdir, :outputs
    
    def initialize flow_id, &blk
      @flow_id = flow_id
      @outputs = []
      namespace @flow_id do
        self.instance_eval(&blk)
      end
    end

    def get_new_output
      raise "No working directory specified." unless @workdir
      file_suffix = rand*10000000.to_i
      @outputs << "#{@workdir}/#{@flow_id}/#{file_suffix}"
      @outputs.last
    end

    def run taskname
      Rake::Task["#{@flow_id}:#{taskname}"].invoke
    end

    def describe
      Rake::Task.tasks.each do |t|
        puts t.inspect if t.name =~ /#{@flow_id}/
      end
    end

  end
end
