require 'pathname'
require 'swineherd/hdfs'
module Swineherd
  module WukongTask
    def self.new_wukong_task job_name, script
      task job_name do
        options = {
          :inputs => {   # input data files
          },
          :output => "",
          :extra_wukong_args => {
          }
        }
        yield options
        system(
          ruby_interpreter_path,
          script, '--run',
          wukong_options(options),
          options[:inputs].join(","),
          options[:output]
          ) if !Hfile.exist?(options[:output])
      end
    end

    def self.wukong_options options
      options.
        reject{|param,val| (param.to_s == 'output') || (param.to_s == 'inputs') }.
        map{|param,val| "--#{param}=#{val}"}.
        join(" ")
    end

    def self.ruby_interpreter_path
      Pathname.new(File.join(
          Config::CONFIG["bindir"],
          Config::CONFIG["RUBY_INSTALL_NAME"]+Config::CONFIG["EXEEXT"])).realpath
    end
    
  end  
end
