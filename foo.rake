require 'rubygems'
require 'wukong'
require 'swineherd' ; include Swineherd

#
# - A workflow has a name and id
# - A workflow has many jobs
# - A workflow can describe jobs by name
# - A workflow can describe full dependency graph as a visualization
# - A job has a name
# - A job has dependencies
# - A job can describe how to run itself
# - A job has a type (pig, wukong, r)
# - A job has a script that is ALWAYS treated as an erb template
# - A job has command line parameters
# - A job has (optional) template parameters
# - A job is idempotent
#

Settings.define :flow_id, :env_var => 'SWINEHERD_FLOW_ID'
Settings.resolve!
options = Settings.dup

# parameters       {:somedata => '/path/to/somedata'}
# attributes       {:schema => 'blargh:chararray', :foo => 'bar'}

Swineherd::WorkFlow.new(options.flow_id) do |jobs|

  jobs[:myjob] = Job.new do
    type             'pig'
    dependencies     [:other_task, :yet_another_task]
    script           'dumb_pig_script.pig'
    output           'out1,out2'
  end
  
end

