#!/usr/bin/env ruby

require 'erubis'

#
# Usage: PigScript.new(source, options).run
#

module Swineherd
  
  class PigScript
    attr_accessor :source_template, :pig_options

    def initialize source_template, pig_options
      @pig_options     = pig_options
      @source_template = source_template
    end

    def run
      compile!
      execute
    end

    def basename
      File.basename(source_filename).gsub(".erb", "")
    end

    def compile!
      dest << source.result(binding()) # or use hash
      dest << "\n"
      dest
    end

    def path
      compiled_file.path
    end

    def execute
      system('../../bin/pigsy.rb', '--pig_classpath=/usr/lib/pig', dest)
    end

    protected

    def source
      File.open(source_filename).read
    end

    def dest
      return @dest if @dest
      @dest ||= Tempfile.new(basename)
    end
  end
end
