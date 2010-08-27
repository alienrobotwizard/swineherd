module Swineherd
  class Azkaban

    #
    # Read in a (.job) file containing key=value pairs and return
    # the obvious hash
    #
    def self.jobfile_settings jobfile
      settings_hsh = {}
      File.readlines(jobfile).each do |line|
        next unless line.include?('=')
        key_value = line.strip.split('=', 2) # only split into 2 pieces
        settings_hsh[key_value.first.to_sym] = key_value.last
      end
      settings_hsh
    end

  end
end
