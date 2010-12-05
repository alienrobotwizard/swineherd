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

    def cmd
      raise "Override this in subclass!"
    end

    def run
      puts cmd
      system "#{cmd}" if HDFS.check_paths(@output)
    end

  end
end
