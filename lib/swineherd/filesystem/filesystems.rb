require 'fileutils'

class FileSystem

  # A factory function that returns an instance of the requested class
  def self.get(scheme, *args)
    if scheme == :file
      LocalFileSystem.new()
    else
      nil
    end
  end
   
  class LocalFileSystem
    
    # Open a file in this filesystem
    def open(path,mode="r",&blk)
      return LocalFile.new(path,mode,&blk)
    end

    # Works like rm -r
    def rm(path)
      FileUtils.rm_r(path)
    end
    
    # Does this exist?
    def exists?(path)
      File.exists?(path)
    end
    
    # Works like UNIX mv
    def mv(srcpath,dstpath)
      FileUtils.mv(srcpath,dstpath)
    end
    
    # Works like UNIX cp -r
    def cp(srcpath,dstpath)
      FileUtils.cp_r(srcpath,dstpath)
    end
    
    # Make directory path if it does not (partly) exist
    def mkpath(path)
      FileUtils.mkpath
    end
    
    # Return file type ("dir" or "file" or "symlink")
    def type(path)
      if File.symlink?(path)
        return "symlink"
      end
      if File.directory?(path)
        return "directory"
      end
      if File.file?(path)
        return "file"
      end
      "unknown"
    end
    
    # Give contained files/dirs
    def entries(dirpath)
      if type(dirpath) != "directory"
        return nil
      end
      Dir.entries(dirpath)
    end
    
    class LocalFile
      attr_accessor :path, :scheme, :mode
      
      def initialize(path,mode="r",&blk)
        @path=path
        @mode=mode
        @handle=File.open(path,mode,&blk)
      end
      
      def open(path,mode="r")
        # Only "r" and "w" modes are supported.
        initialize(path,mode)
      end
      
      # Return whole file and as a string
      def read
        @handle.read
      end
      
      # Return a line from stream
      def readline
        @handle.gets
      end
      
      # Writes to the file
      def write(string)
        @handle.write(string)
      end
      
      # Close file
      def close
        @handle.close
      end
    end
  end
end
