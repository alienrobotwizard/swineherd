require 'rubygems'
require 'configliere' ; Configliere.use(:commandline, :env_var, :define)
require 'rake'

module Swineherd
  autoload :Template,     'swineherd/template'
  autoload :FileSystem,   'swineherd/filesystem'
  autoload :Script,       'swineherd/script'
  autoload :Workflow,     'swineherd/workflow'
end
