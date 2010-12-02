require 'swineherd/hdfs' ; include Swineherd

input  = "s3://s3hdfs.infinitemonkeys.info/data/sn/tw/fixd/current/tweet"
output = "/tmp/streamed/tweet"

task :stream_flat do
  Hfile.stream(input, output)
end

task :default => [:stream_flat]
