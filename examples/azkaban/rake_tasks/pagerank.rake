require 'rubygems'
require 'configliere' # options handling
$: << File.dirname(__FILE__)+"/../../../lib"
require 'swineherd' ; include Swineherd


Settings.define :azk_run_id,          :env_var => 'AZK_RUN_ID',     :required => true, :description => 'An id unique to this run of the entire workflow, see README'
Settings.define :edge_set,            :env_var => 'EDGE_SET',       :required => true, :description => 'Full path to input edge set for calculation'
Settings.define :pagerank_iterations, :env_var => 'PAGERANK_ITERS', :required => true, :description => 'Number of iterations to run pagerank'

Settings.resolve!
options = Settings.dup

task :pagerank_iterate => [:pagerank_initialize]

task :pagerank_initialize do
  data_path     = File.dirname(__FILE__)+"/../data"
  template_path = File.dirname(__FILE__)+"/../templates"
  script_options = {
    :edge_set     => options[:edge_set],
    :initial_rank => 1.0, # initial value of pr to send to all outlinks
    :outputs      => [File.join(data_path, "#{options[:azk_run_id]}/pagerank_graph_0")] # in this case there is only one output
  }
  script_template = File.join(template_path, "pagerank_initialize.pig.erb")
  PigScript.new(script_template, script_options, :mode => 'local').run # run in local mode for example
end

#
# Run pagerank some number of times, outputs that exist are simply
# not ran
#
task :pagerank_iterate do
  options[:pagerank_iterations].to_i.times do |n|
    one_pagerank_iteration n, n+1
  end  
end

#
# Just runs one iteration of pagerank, politely passing if already done
#
def one_pagerank_iteration prev_iter, next_iter
  options = Settings.dup
  data_path     = File.dirname(__FILE__)+"/../data"
  template_path = File.dirname(__FILE__)+"/../templates"
  script_options = {
    :damping_factor => 0.95, # strictly in [0,1.0]
    :current_file   => File.join(data_path,  "#{options[:azk_run_id]}/pagerank_graph_#{prev_iter}"),
    :outputs        => [File.join(data_path, "#{options[:azk_run_id]}/pagerank_graph_#{next_iter}"),]
  }
  script_template = File.join(template_path, "pagerank.pig.erb")
  PigScript.new(script_template, script_options, :mode => 'local').run
end

