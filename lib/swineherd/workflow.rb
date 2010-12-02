module Swineherd
  class WorkFlow
    attr_accessor :flow_id, :jobs
    def initialize(flow_id, &blk)
      namespace flow_id do
        @flow_id = flow_id
        @jobs    = {}
        yield @jobs
      end
    end
  end
end
