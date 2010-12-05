#!/usr/bin/env ruby

require 'rake'
require 'swineherd' ; include Swineherd
require 'swineherd/workflow'

Settings.define :flow_id,    :required => true,                   :description => "Unique id for the workflow"
Settings.define :work_dir,   :default => "/tmp/pagerank_example", :description => "HDFS path to intermediate and final outputs"
Settings.define :iterations, :type => Integer,  :default => 5,    :description => "Number of iterations of pagerank algorithm to run"
Settings.resolve!

Workflow.new(Settings.flow_id) do |flow_id|
  def one_pagerank_iteration n
    script         = PigScript.new('pagerank.pig')
    script.options = {:curr_iter_file => "#{Settings.work_dir}/pagerank_iteration_#{n}", :next_iter_file => "#{Settings.work_dir}/pagerank_iteration_#{n+1}", :damp => "0.85f"}
    script.output  << "#{Settings.work_dir}/pagerank_iteration_#{n+1}"
    script.run
  end

  task :pagerank_initialize do
    script         = PigScript.new('pagerank_initialize.pig')
    script.options = {:adjlist => "#{Settings.work_dir}/seinfeld_network.tsv", :initgrph => "#{Settings.work_dir}/pagerank_iteration_0"}
    script.output  << "#{Settings.work_dir}/pagerank_iteration_0"
    script.run
  end

  task :pagerank_iterate => [:pagerank_initialize] do
    Settings.iterations.to_i.times do |i|
      one_pagerank_iteration i
    end
  end

  task :cut_off_adjacency_list => [:pagerank_iterate] do
    script = WukongScript.new('cut_off_list.rb')
    script.input  << "#{Settings.work_dir}/pagerank_iteration_#{Settings.iterations.to_i - 1}"
    script.output << "#{Settings.work_dir}/pagerank_result"
    script.run
  end

  #
  # Pull results into local directory with same name
  #
  task :pull_down_results => [:cut_off_adjacency_list] do
    HDFS.cat_to_local("#{Settings.work_dir}/pagerank_result", "#{Settings.work_dir}/pagerank_result.tsv")
  end

  #
  # Plot 2nd column as a histogram (requires R and ggplot2)
  #
  task :plot_results =>  [:pull_down_results] do
    script = RScript.new('histogram.R')
    script.attributes = {
      :pagerank_data => "#{Settings.work_dir}/pagerank_result.tsv",
      :plot_file     => "#{Settings.work_dir}/pagerank_plot.png",
      :raw_rank      => "aes(x=d$V2)"

    }
    script.output << "#{Settings.work_dir}/pagerank_plot.png"
    script.run true # run locally
  end

end.run(:plot_results)
