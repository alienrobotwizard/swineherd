module Swineherd
  class Workflow

    def initialize flow_id, &blk
      @flow_id = flow_id
      namespace @flow_id do
        yield flow_id
      end
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
