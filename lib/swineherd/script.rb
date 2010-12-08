require 'swineherd/localfs'
module Swineherd
  class Script
    attr_accessor :output, :options, :attributes
    def initialize(source, output = [], options = {}, attributes ={})
      @source     = source
      @output     = output
      @options    = options
      @attributes = attributes
    end

    def script
      @script ||= Template.new(@source, @attributes).substitute!
    end

    def refresh!
      @script = nil
    end

    def cmd
      raise "Override this in subclass!"
    end

    def run local=false
      puts cmd
      if local
        system "#{cmd}" if LocalFS.check_paths(@output)
      else
        system "#{cmd}" if HDFS.check_paths(@output)
      end
    end

  end
end
