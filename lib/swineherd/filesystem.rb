module Swineherd
  autoload :BaseFileSystem,   'filesystem/basefilesystem'
  autoload :LocalFileSystem,  'filesystem/localfilesystem'
  autoload :HadoopFileSystem, 'filesystem/hadoopfilesystem'

  class FileSystem
    # A factory function that returns an instance of the requested class
    def self.get(scheme, *args)
      case sheme
      when :file then
        LocalFileSystem.new
      when :hdfs then
        HadoopFileSystem.new
      else
        raise "Filesystem with scheme #{scheme} does not exist."
      end
    end

  end

end
