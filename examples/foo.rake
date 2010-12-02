require 'swineherd'

# invoke with 'rake -f foo.rake my_flow_id_1234:myjob'

flow_id = 'my_flow_id_1234'
flow = Swineherd::WorkFlow.new(flow_id) do |jobs|

  myjob = Swineherd::Job.new do
    type             'pig'
    name             :myjob
    dependencies     [:other_task, :yet_another_task]
    pig_opts         '-Dmapred.reduce.tasks=100'
    parameters       ({:foo => 'bar', :this => 'that'})
    attributes       ({:input => 'some_input_path', :schema => 'field_1:chararray, field_2:float'})
    script           'some_pig_script.pig'
    output           'out1,out2'
  end
  jobs[myjob.name] = myjob

end
