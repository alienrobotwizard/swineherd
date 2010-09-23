#!/usr/bin/env ruby

require 'rubygems'
require 'swineherd/r_script' ; include Swineherd

opts = {:outputs => ['sin_x.png']}
src  = 'plot_sin_x.r.erb'

RScript.new(src, opts).run
