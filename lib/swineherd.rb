require 'rubygems'
require 'configliere' ; Configliere.use(:commandline, :env_var, :define)

module Swineherd
  autoload :Template,     'swineherd/template'
  autoload :HDFS,         'swineherd/hdfs'
  autoload :Script,       'swineherd/script'
  autoload :Pig,          'swineherd/pig'
  autoload :Wukong,       'swineherd/wukong'
  autoload :PigScript,    'swineherd/pig_script'
  autoload :WukongScript, 'swineherd/wukong_script'
end
