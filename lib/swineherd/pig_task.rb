#!/usr/bin/env ruby
require 'swineherd/hdfs'

module Swineherd
  module PigTask
    #
    # The use case here is really for existing scripts that are not erb templates.
    # Use the PigScript class if you are coding from scratch.
    #    
    def self.new_pig_task job_name, script
      task job_name do
        options = {
          :inputs => {    # input data files
          },
          :outputs => {   # output data files, will be checked for existence
          },
          :extra_pig_params => { # other params
          }
        }
        yield options
        system('pigsy.rb', *[pig_args(options), script].flatten) if check_outputs(options[:outputs])
      end
    end

    #
    # Needs to return true if no outputs exist, false otherwise,
    # raise error if some do and some dont
    #
    def self.check_outputs outputs
      exist_count   = 0 # no outputs exist
      outputs.values.each{|hdfs_path| exist_count += 1 if Hfile.exist?(hdfs_path) }
      raise "Indeterminate output state" if (exist_count > 0) && (exist_count < outputs.values.size)
      return true if exist_count == 0
      false
    end

    def self.pig_args options
      args = []
      options.each do |option_type, arg_pairs|
        arg_pairs.each do |opt, val|
          args << ['-p', "#{opt.to_s.upcase}=#{val}"]
        end
      end
      args.flatten
    end
  end
end
