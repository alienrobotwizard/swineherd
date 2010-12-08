#!/usr/bin/env ruby

require 'swineherd' ; include Swineherd
require 'swineherd/workflow'
require 'swineherd/workflow/job'

Settings.define :flow_id,    :required => true
Settings.define :iterations, :type => Integer, :default => 10
Settings.resolve!

flow = Workflow.new(Settings.flow_id) do
  
  initializer = PigScript.new('pagerank_initialize.pig')
  iterator    = PigScript.new('pagerank.pig')
  finisher    = WukongScript.new('cut_off_list.rb')

  task :pagerank_initialize do
    initializer.output << next_output(:pagerank_initialize)
    initializer.options = {:adjlist => "/tmp/pagerank_example/seinfeld_network.tsv", :initgrph => initializer.output}
    initializer.run
  end
  
  task :pagerank_iterate => [:pagerank_initialize] do
    iterator.options[:damp]           = '0.85f'
    iterator.options[:curr_iter_file] = latest_output(:pagerank_initialize)
    Settings.iterations.times do
      iterator.output                   << next_output(:pagerank_iterate)
      iterator.options[:next_iter_file] = latest_output(:pagerank_iterate)
      iterator.run
      iterator.refresh!
      iterator.options[:curr_iter_file] = latest_output(:pagerank_iterate)
    end
  end

  task :cut_off_adjacency_list => [:pagerank_iterate] do
    finisher.input  << latest_output(:pagerank_iterate)
    finisher.output << next_output(:cut_off_adjacency_list)
    finisher.run
  end
  
end

flow.workdir = "/tmp/pagerank_example"
flow.describe
flow.run(:cut_off_adjacency_list)
# flow.clean!
