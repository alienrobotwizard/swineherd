require 'rubygems'
require 'configliere' ; Configliere.use(:commandline, :env_var, :define)

Settings.define :verbose, :default => false, :description => "Print commands before running"
Settings.resolve!

module Swineherd
  autoload :WorkFlow,   'swineherd/workflow'
  autoload :Job,        'swineherd/job'
  autoload :Template,   'swineherd/template'
  autoload :HDFS,       'swineherd/hdfs'
  autoload :Pig,        'swineherd/pig'
end
