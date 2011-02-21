#!/usr/bin/env ruby

$LOAD_PATH << '../../lib'
require 'swineherd'        ; include Swineherd
require 'swineherd/script' ; include Swineherd::Script
require 'swineherd/filesystem'

Settings.define :flow_id,     :required => true,                     :description => "Flow id required to make run of workflow unique"
Settings.define :iterations,  :type => Integer,  :default => 10,     :description => "Number of pagerank iterations to run"
Settings.define :hadoop_home, :default => '/usr/local/share/hadoop', :description => "Path to hadoop config"
Settings.resolve!

flow = Workflow.new(Settings.flow_id) do

  # The filesystems we're going to be working with
  hdfs    = Swineherd::FileSystem.get(:hdfs)
  localfs = Swineherd::FileSystem.get(:file)

  # The scripts we're going to use
  initializer = PigScript.new('scripts/pagerank_initialize.pig')
  iterator    = PigScript.new('scripts/pagerank.pig')
  finisher    = WukongScript.new('scripts/cut_off_list.rb')
  plotter     = RScript.new('scripts/histogram.R')

  #
  # Runs simple pig script to initialize pagerank. We must specify the input
  # here as this is the first step in the workflow. The output attribute is to
  # ensure idempotency and the options attribute is the hash that will be
  # converted into command-line args for the pig interpreter.
  #
  task :pagerank_initialize do
    initializer.options = {:adjlist => "/tmp/pagerank_example/seinfeld_network.tsv", :initgrph => next_output(:pagerank_initialize)}
    initializer.run(:hadoop) unless hdfs.exists? latest_output(:pagerank_initialize)
  end

  #
  # Runs multiple iterations of pagerank with another pig script and manages all
  # the intermediate outputs.
  #
  task :pagerank_iterate => [:pagerank_initialize] do
    iterator.options[:damp]           = '0.85f'
    iterator.options[:curr_iter_file] = latest_output(:pagerank_initialize)
    Settings.iterations.times do
      iterator.options[:next_iter_file] = next_output(:pagerank_iterate)
      iterator.run(:hadoop) unless hdfs.exists? latest_output(:pagerank_iterate)
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
    finisher.run :hadoop unless hdfs.exists? latest_output(:cut_off_adjacency_list)
  end

  #
  # We want to pull down one result file, merge the part-000.. files into one file
  #
  task :merge_results => [:cut_off_adjacency_list] do
    merged_results = next_output(:merge_results)
    hdfs.merge(latest_output(:cut_off_adjacency_list), merged_results) unless hdfs.exists? merged_results
  end

  #
  # Cat results into a local directory with the same structure
  # eg. #{work_dir}/#{flow_id}/pull_down_results-0.
  #
  # FIXME: Bridging filesystems is cludgey.
  #
  task :pull_down_results => [:merge_results] do
    local_results = next_output(:pull_down_results)
    hdfs.copy_to_local(latest_output(:merge_results), local_results) unless localfs.exists? local_results
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
    plotter.run(:hadoop) unless localfs.exists? latest_output(:plot_results)
  end

end

flow.workdir = "/tmp/pagerank_example"
flow.describe
flow.run(:plot_results)
