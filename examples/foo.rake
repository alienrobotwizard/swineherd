require 'swineherd'

Settings.define :flow_id, :required => true
Settings.define :reduce_tasks
Settings.resolve!

flow = Swineherd::WorkFlow.new(Settings.flow_id) do |jobs|

  myjob = Swineherd::Job.new(Settings.flow_id) do
    type             'pig'
    name             :myjob
    pig_opts         "-Dmapred.reduce.tasks=#{Settings.reduce_tasks}"
    parameters       ({:foo => 'bar', :this => 'that'})
    attributes       ({:input => 'some_input_path', :schema => 'field_1:chararray, field_2:float'})
    script           'some_pig_script.pig'
    pig_output       'foo'
  end
  jobs[myjob.name] = myjob
end
