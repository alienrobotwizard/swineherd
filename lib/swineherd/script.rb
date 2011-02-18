require 'swineherd/filesystem'
module Swineherd
  module Script
    module Common
      attr_accessor :input, :output, :options, :attributes
      def initialize(source, input = [], output = [], options = {}, attributes ={})
        @source     = source
        @input      = input
        @output     = output
        @options    = options
        @attributes = attributes
      end

      def script
        @script ||= Template.new(@source, @attributes).substitute!
      end

      #
      # So we can reuse ourselves
      #
      def refresh!
        @script = nil
        @output = []
        @input  = []
      end

      #
      # This depends on the type of script
      #
      def cmd
        raise "Override this in subclass!"
      end

      #
      # Override this in subclass to decide how script runs in 'local' mode
      # Best practice is that it needs to be able to run on a laptop w/o
      # hadoop.
      #
      def local_cmd
        raise "Override this in subclass!"
      end

      #
      # Default is to run with hadoop
      #
      def run mode=:hadoop
        case mode
        when :local then
          localfs = FileSystem.get :file
          sh local_cmd if localfs.check_paths(@output)
        when :hadoop then
          hdfs = FileSystem.get :hdfs
          sh cmd if hdfs.check_paths(@output)
        end
      end

    end
  end
end
