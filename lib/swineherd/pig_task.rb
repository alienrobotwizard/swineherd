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
        run_mode ||= (options[:extra_pig_params][:mode] || 'mapreduce')
        system('echo', 'pigsy.rb', *["--mode=#{run_mode}", pig_args(options), script].flatten)
        exec('pigsy.rb', *["--mode=#{run_mode}", pig_args(options), script].flatten) if check_outputs(options[:outputs])
      end
    end

    #
    # Needs to return true if no outputs exist, false otherwise,
    # raise error if some do and some dont
    #
    def self.check_outputs outputs
      Hfile.check_paths(outputs.values)
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
