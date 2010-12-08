require 'swineherd/localfs'
module Swineherd
  module Script
    module Common
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

      #
      # So we can reuse ourselves
      #
      def refresh!
        @script = nil
        @output = []
      end

      #
      # This depends on the type of script
      #
      def cmd
        raise "Override this in subclass!"
      end
      #
      # Default is to run with hadoop
      #
      def run local=false
        puts cmd
        if local
          sh "#{cmd}" if LocalFS.check_paths(@output)
        else
          sh "#{cmd}" if HDFS.check_paths(@output)
        end
      end

    end
  end
end
