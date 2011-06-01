module Swineherd
  module Script

    autoload :WukongScript, 'swineherd/script/wukong_script'
    autoload :PigScript,    'swineherd/script/pig_script'
    autoload :RScript,      'swineherd/script/r_script'

    module Common
      
      attr_accessor :input, :output, :options, :attributes
      def initialize(source, input = [], output = [], options = {}, attributes ={})
        @source     = source
        @input      = input
        @output     = output
        @options    = options
        @attributes = attributes
      end

      #
      # Allows for setting the environment the script will be ran in
      #
      def env
        ENV
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
          sh local_cmd do |res, ok|
            Log.info("Exit status was #{ok}")
            raise "Local mode script failed with exit status #{ok}" if ok != 0
          end
        when :hadoop then
          sh cmd do |res, ok|
            Log.info("Exit status was #{ok}")
            raise "Hadoop mode script failed with exit status #{ok}" if ok != 0
          end
        end
      end

    end
  end
end
