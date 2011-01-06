#!/usr/bin/env ruby

require 'rubygems'
require 'wukong'

#
# Does the very simple job of cutting of the giant adjacency list
#
class CutMapper < Wukong::Streamer::RecordStreamer
  def process *args
    node_a, node_b, list = args
    yield [node_a, node_b]
  end
end

Wukong::Script.new(CutMapper, nil).run
