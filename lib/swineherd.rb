require 'rubygems'
require 'configliere' ; Configliere.use(:commandline, :env_var, :define)

#
# Autoload workflow, job, hdfs, and pig classes by default
#
module Swineherd
  autoload :WorkFlow,   'swineherd/workflow'
  autoload :Job,        'swineherd/job'
  autoload :HDFS,       'swineherd/hdfs'
  autoload :Pig,        'swineherd/pig'
end
