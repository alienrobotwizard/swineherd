module Swineherd

  #
  # All methods a filesystem should have
  #
  module BaseFileSystem

    #
    # Return a new instance of 'this' filesystem. Classes that include this
    # module are expected to know how to pull their particular set of arguments
    # from *args and initialize themselves by opening any required connections, &c.
    #
    def initialize *args
    end

    #
    # Open a file in this filesystem. Should return a usable file handle for in
    # the mode (read 'r' or 'w') given. File classes should, at minimum, have
    # the methods defined in BaseFile
    #
    def open path, mode="r", &blk
    end

    #
    # Recursively delete the path and all paths below it.
    #
    def rm path
    end

    #
    # Returns true if the file or path exists and false otherwise.
    #
    def exists? path
    end

    #
    # Moves the source path to the destination path
    #
    def mv srcpath, dstpath
    end

    #
    # Recursively copies all files and directories under srcpath to dstpath
    #
    def cp srcpath, dstpath
    end

    #
    # Make directory path if it does not (partly) exist
    #
    def mkpath path
    end

    #
    # Return file type ("directory" or "file" or "symlink")
    #
    def type path
    end

    #
    # Give contained files/dirs
    #
    def entries dirpath
    end

    #
    # Needs to close the filesystem by cleaning up any open connections, &c.
    #
    def close *args
    end

    class BaseFile
      attr_accessor :path, :scheme, :mode


      def initialize *args, &blk
      end

      #
      # A new file in the filesystem needs to be instantiated with a
      # path, a mode (read 'r' or write 'w').
      #
      def open path, mode="r", &blk
      end

      #
      # Return whole file and as a string
      #
      def read
      end

      #
      # Return a line from stream
      #
      def readline
      end

      #
      # Writes a string to the file
      #
      def write string
      end

      #
      # Close the file
      #
      def close *args
      end

    end

  end

end
