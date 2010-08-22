#
# Example of creating a pig_task with swineherd
#
require 'swineherd' ; include Swineherd

#
# The following expects a pig script, 'foo.pig', to
# exist. Results in:
#
# piggy.rb -p IN=foo.tsv -p OUT=/tmp/foo.tsv -p N=1L foo.pig
#
# And is executed when you do:
#
# rake -f pigtask.rake foopig
#
PigTask.new_pig_task(:foopig, 'foo.pig') do |options|
  options[:inputs]           = {:in  => 'foo.tsv'}
  options[:outputs]          = {:out => '/tmp/foo.tsv'}
  options[:extra_pig_params] = {:n   => '1L'}
end
