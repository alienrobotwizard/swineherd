#!/usr/bin/env ruby
require 'swineherd/hdfs'

#
# Example usage:
#
# PigTask.run_pig_job(:foobar, "foo.pig",
#   {
#     :inputs => {
#       :in => "jobs.schedule"
#     },
#     :outputs => {
#       :out => "/tmp/jobs.schedule"
#     },
#     :extra_pig_params => {
#     }
#   })
#


module Swineherd
  module PigTask
    #
    # Does the actual running of the pig job
    #
    def self.run_pig_job job_name, script, options
      task job_name do
        system('echo', '../../bin/piggy.rb', *[pig_args(options), script].flatten) if check_outputs(options[:outputs])
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
