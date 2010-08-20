#!/usr/bin/env ruby

require 'swineherd' ; include Swineherd
require 'wukong'
require 'wukong/schema'

#
# TypedStructs have a nifty "to_pig" method
#
class AdjPair < TypedStruct.new(
    [:node_a,   String ],
    [:node_b,   String ]
    )
end

options = {
  :graph       => 'seinfeld_network.tsv',
  :degree_dist => '/tmp/degree_dist'
}
    
PigScript.new('degree_distribution.pig.erb', options, :mode => 'local').run
