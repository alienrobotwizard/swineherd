Settings.define :flow_id,    :required => true
Settings.define :iterations, :type => Integer, :default => 10
Settings.resolve!

class Workflow
  def initialize flow_id, &blk
    self.instance_eval(&blk)
  end

  def get_new_output
    # funky stuff
  end
  
end

flow = Workflow.new(flow_id) do
  
  initializer = PigScript.new('pagerank_initialize.pig')
  iterator    = PigScript.new('pagerank.pig')
  
  task :pagerank_initialize do
    initializer.output  = get_new_output
    initializer.options = {:adjlist => "/my-adj-list", :initgrph => initializer.output}
    initializer.run
  end
  
  task :pagerank_iterate => [:pagerank_initialize] do
    iterator.options[:damp]   = '0.85f'
    iterator[:curr_iter_file] = initializer.output
    Settings.iterations.times do
      iterator.output = get_new_output
      iterator.options[:next_iter_file] = iterator.output
      iterator.run
      iterator.options[:curr_iter_file] = iterator.output
    end  
  end
  
end

flow.workdir = "/tmp/foobar"
flow.run(:pagerank_iterate)
flow.clean!
