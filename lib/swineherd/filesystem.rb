module Swineherd
  autoload :BaseFileSystem,   'swineherd/filesystem/basefilesystem'
  autoload :LocalFileSystem,  'swineherd/filesystem/localfilesystem'
  autoload :HadoopFileSystem, 'swineherd/filesystem/hadoopfilesystem'
  autoload :S3FileSystem,     'swineherd/filesystem/s3filesystem'

  class FileSystem

    FILESYSTEMS = {
      'file' => Swineherd::LocalFileSystem,
      'hdfs' => Swineherd::HadoopFileSystem,
      's3'   => Swineherd::S3FileSystem
    }

    # A factory function that returns an instance of the requested class
    def self.get scheme, *args
      begin
        FILESYSTEMS[scheme.to_s].new *args
      rescue NoMethodError => e
        raise "Filesystem with scheme #{scheme} does not exist.\n #{e.message}"
      end
    end

  end

end
