require 'fileutils'
module Swineherd

  class LocalFileSystem

    include Swineherd::BaseFileSystem

    def initialize *args
    end

    def open path, mode="r", &blk
      return LocalFile.new path, mode, &blk
    end

    def rm path
      FileUtils.rm_r path
    end

    def exists? path
      File.exists?(path)
    end

    def mv srcpath, dstpath
      FileUtils.mv(srcpath,dstpath)
    end

    def cp srcpath, dstpath
      FileUtils.cp_r(srcpath,dstpath)
    end

    def mkpath path
      FileUtils.mkpath path
    end

    def type path
      case
      when File.symlink?(path) then
        return "symlink"
      when File.directory?(path) then
        return "directory"
      when File.file?(path) then
          return "file"
      end
      "unknown"
    end

    def entries dirpath
      return unless (type(dirpath) == "directory")
      Dir.entries(dirpath)
    end

    class LocalFile
      attr_accessor :path, :scheme, :handle, :mode

      def initialize path, mode="r", &blk
        @path   = path
        @mode   = mode
        @handle = File.open(path,mode,&blk)
      end

      def open path, mode="r", &blk
        initialize(path,mode,&blk)
      end

      def read
        @handle.read
      end

      def readline
        @handle.gets
      end

      def write string
        @handle.write(string)
      end

      def close
        @handle.close
      end
    end

  end
end
