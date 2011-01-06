#!/usr/bin/env ruby

require 'swineherd' ; include Swineherd
require 'swineherd/script/pig_script' ; include Swineherd::Script
require 'swineherd/script/wukong_script'

Settings.define :flow_id,    :required => true,                 :description => "Flow id required to make run of workflow unique"
Settings.define :iterations, :type => Integer,  :default => 10, :description => "Number of pagerank iterations to run"
Settings.resolve!

flow = Workflow.new(Settings.flow_id) do

  initializer = PigScript.new('pagerank_initialize.pig')
  iterator    = PigScript.new('pagerank.pig')
  finisher    = WukongScript.new('cut_off_list.rb')
  plotter     = RScript.new('histogram.R')

  #
  # Runs simple pig script to initialize pagerank. We must specify the input
  # here as this is the first step in the workflow. The output attribute is to
  # ensure idempotency and the options attribute is the hash that will be
  # converted into command-line args for the pig interpreter.
  #
  task :pagerank_initialize do
    initializer.output << next_output(:pagerank_initialize)
    initializer.options = {:adjlist => "/tmp/pagerank_example/seinfeld_network.tsv", :initgrph => latest_output(:pagerank_initialize)}
    initializer.run
  end

  #
  # Runs multiple iterations of pagerank with another pig script and manages all
  # the intermediate outputs.
  #
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

  #
  # Here we use a wukong script to cut off the last field (a big pig bag of
  # links). Notice how every wukong script MUST have an input but pig scripts do
  # not.
  #
  task :cut_off_adjacency_list => [:pagerank_iterate] do
    finisher.input  << latest_output(:pagerank_iterate)
    finisher.output << next_output(:cut_off_adjacency_list)
    finisher.run
  end

  #
  # Cat results into a local directory with the same structure eg. #{work_dir}/#{flow_id}/pull_down_results-0
  #
  task :pull_down_results => [:cut_off_adjacency_list] do
    HDFS.cat_to_local(latest_output(:pagerank_iterate), next_output(:pull_down_results))
  end

  #
  # Plot 2nd column of the result as a histogram (requires R and
  # ggplot2). Note that the output here is a png file but doesn't have that
  # extension. Ensmarten me as to the right way to handle that?
  #
  task :plot_results =>  [:pull_down_results] do
    plotter.attributes = {
      :pagerank_data => latest_output(:pull_down_results),
      :plot_file     => next_output(:plot_results), # <-- this will be a png...
      :raw_rank      => "aes(x=d$V2)"
    }
    plotter.output << latest_output(:plot_result)
    script.run true # <-- run locallly
  end

end

flow.workdir = "/tmp/pagerank_example"
flow.describe
flow.run(:plot_results)
# flow.clean!
