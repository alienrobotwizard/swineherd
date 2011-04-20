require 'rubygems'
require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "swineherd"
  gem.homepage = "http://github.com/Ganglion/swineherd"
  gem.license = "MIT"
  gem.summary = %Q{Flexible data workflow glue.}
  gem.description = %Q{Swineherd is for running scripts and workflows on filesystems.}
  gem.email = "jacob.a.perkins@gmail.com"
  gem.authors = ["Jacob Perkins"]
  # Include your dependencies below. Runtime dependencies are required when using your gem,
  # and development dependencies are only needed for development (ie running rake tasks, tests, etc)
  #  gem.add_runtime_dependency 'jabber4r', '> 0.1'
  #  gem.add_development_dependency 'rspec', '> 1.2.3'
  gem.add_development_dependency "yard", "~> 0.6.0"
  gem.add_development_dependency "jeweler", "~> 1.5.2"
  gem.add_development_dependency "rcov", ">= 0"
  gem.add_dependency 'configliere'
  gem.add_dependency 'gorillib'
  gem.add_dependency 'erubis'
  gem.add_dependency 'right_aws'
end
Jeweler::RubygemsDotOrgTasks.new


require 'yard'
YARD::Rake::YardocTask.new
