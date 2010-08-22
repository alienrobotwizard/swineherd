#!/usr/bin/env ruby
require 'rubygems'
require 'wukong'
require 'wukong/streamer/count_keys'

class Mapper < Wukong::Streamer::LineStreamer
  def tokenize str
    return [] unless str
    str = str.downcase;
    str = str.
      gsub(/[^a-zA-Z0-9\']+/, ' ').
      gsub(/(\w)\'([st])\b/, '\1!\2').gsub(/\'/, ' ').gsub(/!/, "'")
    words = str.strip.split(/\s+/)
    words.reject!{|w| w.blank? }
    words
  end

  def process line
    tokenize(line).each{|word| yield [word, 1]}
  end
end

Wukong::Script.new(Mapper, Wukong::Streamer::CountKeys).run
