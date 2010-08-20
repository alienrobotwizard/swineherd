#!/usr/bin/env ruby

require 'erubis'
require 'tempfile'

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
      File.basename(source_template)
    end

    def compile!
      dest << Erubis::Eruby.new(source).result(pig_options)
      dest << "\n"
      dest
    end

    #
    # "pigsy.rb" is the superior runner to "pig", put it in your path
    #
    def execute
      dest.read # wtf? why is this necessary, to late at night for me...
      system('pigsy.rb', '--pig_home=/usr/local/share/pig', '--pig_classpath=/usr/local/share/hadoop/conf', dest.path)
    end

    protected

    def source
      File.open(source_template).read
    end

    def dest
      return @dest if @dest
      @dest ||= Tempfile.new(basename)
    end
  end
end
