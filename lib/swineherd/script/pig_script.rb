module Swineherd::Script
  class PigScript
    include Common

    #
    # Not guaranteeing anything.
    #
    AVRO_PIG_MAPPING = {
      'string' => 'chararray',
      'int'    => 'int',
      'long'   => 'long',
      'float'  => 'float',
      'double' => 'double',
      'bytes'  => 'bytearray',
      'fixed'  => 'bytearray'
    }

    #
    # Simple utility function for mapping avro types to pig types
    #
    def self.avro_to_pig avro_type
      AVRO_PIG_MAPPING[avro_type]
    end

    #
    # Convert a generic hash of options {:foo => 'bar'} into
    # command line options for pig '-p FOO=bar'
    #
    def pig_args options
      options.map{|opt,val| "-p #{opt.to_s.upcase}=#{val}" }.join(' ')
    end



    def local_cmd
      Log.info("Launching Pig script in local mode")
      "pig -x local #{pig_args(@options)} #{script}"
    end

    def cmd
      Log.info("Launching Pig script in hadoop mode")
      "pig #{pig_args(@options)} #{script}"
    end

  end
end
