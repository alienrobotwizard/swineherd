module Swineherd
  autoload :BaseFileSystem,   'swineherd/filesystem/basefilesystem'
  autoload :LocalFileSystem,  'swineherd/filesystem/localfilesystem'
  autoload :HadoopFileSystem, 'swineherd/filesystem/hadoopfilesystem'

  class FileSystem
    # A factory function that returns an instance of the requested class
    def self.get scheme, *args
      case scheme
      when :file then
        Swineherd::LocalFileSystem.new *args
      when :hdfs then
        Swineherd::HadoopFileSystem.new *args
      else
        raise "Filesystem with scheme #{scheme} does not exist."
      end
    end

  end

end
