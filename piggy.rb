#!/usr/bin/env ruby

# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# 
# The Pig command script, ruby-ified! Please make copious improvements.
#

require 'rubygems'
require 'configliere' ; Configliere.use(:commandline, :env_var, :define)

Settings.define :pig_home,        :default => '/usr/local/share/pig',        :env_var => 'PIG_HOME',        :description => 'Path to pig installation'
Settings.define :pig_heap_size,   :default => '-Xmx1000m',                   :env_var => 'JAVA_HEAP_MAX',   :description => 'Java maximum heap size'
Settings.define :pig_classpath,   :default => '/etc/hadoop/conf',            :env_var => 'PIG_CLASSPATH',   :description => 'Extra java classpath entries'
Settings.define :java_home,       :default => '/usr/lib/jvm/java-6-sun/jre', :env_var => 'JAVA_HOME',       :description => 'Path to java installation'
Settings.define :pig_log_dir,     :default => '/usr/local/share/pig/logs',   :env_var => 'PIG_LOG_DIR',     :description => 'Place log files go'
Settings.define :pig_log_file,    :default => 'pig.log',                     :env_var => 'PIG_LOG_FILE',    :description => ''
Settings.define :pig_root_logger, :default => 'INFO,console',                :env_var => 'PIG_ROOT_LOGGER', :description => 'The root appender, can this be more descriptive?'
Settings.define :config,          :default => '/usr/local/share/pig/conf',                                  :description => 'Configuration directory'
Settings.define :pig_opts,                                                   :env_var => 'PIG_OPTS',        :description => 'Further options for pig'
Settings.define :debug,                                                                                     :description => 'Run in debug mode'

Settings.resolve!
options = Settings.dup

java               = "#{options[:java_home]}/bin/java"
hadoop_lib_version = /hadoop20/
pig_main_class     = 'org.apache.pig.Main'

#
# If env variables exist in pig-env.sh, use them
#
pig_conf_file = File.join(options[:config], 'pig-env.sh')
system("source", pig_conf_file) if File.exist? pig_conf_file

#
# Set pig classpath
#
classpath = [options[:config]]
classpath << "#{options[:java_home]}/lib/tools.jar"

Dir["#{options[:pig_home]}/pig-*-core.jar"].each{|jar| classpath << jar}
Dir["#{options[:pig_home]}/build/pig-*-core.jar"].each{|jar| classpath << jar}

Dir["#{options[:pig_home]}/lib/*.jar"].each do |libjar|
  if libjar =~ /.*hadoop.*/
    classpath << libjar if libjar =~ hadoop_lib_version
  else
    classpath << libjar
  end
end

classpath << options[:pig_classpath]


#
# Initialize pig_opts with env values, and defaults
#
pig_opts = [options[:pig_opts]]
pig_opts << "-Dpig.log.dir=#{options[:pig_log_dir]}"
pig_opts << "-Dpig.log.file=#{options[:pig_log_file]}"
pig_opts << "-Dpig.home.dir=#{options[:pig_home]}"
pig_opts << "-Dpig.root.logger=#{options[:pig_root_logger]}"

#
# Go pig, go!
#
if options[:debug] == true
  system('echo',java,options[:pig_heap_size],pig_opts.join(' '), '-classpath', classpath.join(':'), pig_main_class, other_args)
else
  system(java,options[:pig_heap_size],pig_opts.join(' '), '-classpath', classpath.join(':'), pig_main_class, *ARGV)
end  
