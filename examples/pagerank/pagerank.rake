require 'rake'
require 'swineherd' ; include Swineherd

Settings.define  :iterations, :default => '15',  :description => "Number of iterations of pagerank algorithm to run"
Settings.resolve!

def one_pagerank_iteration n
  script         = PigScript.new('pagerank.pig')
  script.options = {:curr_iter_file => "/tmp/pagerank_example/pagerank_iteration_#{n}", :next_iter_file => "/tmp/pagerank_example/pagerank_iteration_#{n+1}", :damp => "0.85f"}
  script.output  << "/tmp/pagerank_example/pagerank_iteration_#{n+1}"
  script.run
end

task :pagerank_initialize do
  script         = PigScript.new('pagerank_initialize.pig')
  script.options = {:adjlist => '/tmp/pagerank_example/seinfeld_network.tsv', :initgrph => '/tmp/pagerank_example/pagerank_iteration_0'}
  script.output  << "/tmp/pagerank_example/pagerank_iteration_0"
  script.run
end

task :pagerank_iterate => [:pagerank_initialize] do
  Settings.iterations.to_i.times do |i|
    one_pagerank_iteration i
  end
end

task :cut_off_adjacency_list => [:pagerank_iterate] do
  script = WukongScript.new('cut_off_list.rb')
  script.input  << "/tmp/pagerank_example/pagerank_iteration_#{Settings.iterations.to_i - 1}"
  script.output << "/tmp/pagerank_example/pagerank_result"
  script.run
end
