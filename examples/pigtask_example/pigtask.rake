#
# Example of creating a pig_task with swineherd
#
require 'swineherd' ; include Swineherd

#
# Here we use the pig_script class to create
# a new pig script to run. Alternatively, there could
# be an existing script on disk.
#

script = PigScript.new('foo.pig')
script.inscribe! do |s|
  s << "data = LOAD '$IN' AS (c1:int, c2:int, c3:int);"
  s << "head = LIMIT data $N;"
  s << "STORE head INTO '$OUT';"
end

PigTask.run_pig_job(:foobar, script.script_name,
  {
    :inputs => {
      :in => "foo.tsv"
    },
    :outputs => {
      :out => "/tmp/foo.tsv"
    },
    :extra_pig_params => {
      :n => '1L'
    }
  })
