#!/usr/bin/env ruby

# require 'erb'

#
# FIXME: this should allow for using erb templates for
# pig scripts
#

# options = {
#   :script_name   => 'foo.pig',
#   :erb_templates => {
#   }
# }

module Swineherd
  class PigScript

    attr_accessor :script_name
    
    PIG_SCRIPT_DIR = '/tmp/swineherd'
    
    def initialize script_name, options = {}
      @script_name = script_name
    end

    def inscribe! &blk
      File.open(script_name, 'w') do |f|
        yield f
      end      
    end

    def execute!      
    end
    
  end

end
