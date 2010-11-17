require 'rubygems'
require 'swineherd/hdfs' ; include Swineherd
require 'configliere'; Configliere.use(:commandline, :env_var, :define)

Settings.define :input, :type => Array
Settings.define :output, :default => "/tmp/streamed"
Settings.resolve!

desc "Run hdp-stream-flat on file"
task :stream do
  Settings.input.each do |input|
    bname  = File.basename(input)
    output = File.join(Settings.output, bname)
    Hfile.stream(input, output) unless HFile.exist?(output)
  end
end

task :default => [:stream]

