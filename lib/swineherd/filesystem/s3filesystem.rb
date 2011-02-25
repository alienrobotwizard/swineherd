require 'right_aws'
module Swineherd

  #
  # Methods for interacting with Amazon's Simple Store Service (s3).
  #
  class S3FileSystem

    include Swineherd::BaseFileSystem

    attr_accessor :s3

    #
    # Initialize a new hadoop file system, needs path to hadoop configuration
    #
    def initialize aws_access_key_id, aws_secret_access_key
      @s3 = RightAws::S3.new(aws_access_key_id, aws_secret_access_key)
    end

    def open path, mode="r", &blk
      # HadoopFile.new(path,mode,self,&blk)
    end


    def rm path
      # @hdfs.delete(Path.new(path), true)
      # [path]
    end

    def bucket path
      uri = URI.parse(path)
      uri.path.split('/').reject{|x| x.empty?}.first
    end

    def prefix path
      uri = URI.parse(path)
      File.join(uri.path.split('/').reject{|x| x.empty?}[1..-1])
    end

    def needs_trailing_slash pre
      has_trailing_slash = pre.end_with? '/'
      is_empty_prefix    = pre.empty?
      !(has_trailing_slash || is_empty_prefix)
    end

    def full_contents path
      pre = prefix(path)
      pre += '/' if needs_trailing_slash(pre)
      contents = []
      s3.interface.incrementally_list_bucket(bucket(path), {'prefix' => pre, 'delimiter' => '/'}) do |res|
        contents += res[:common_prefixes]
        contents += res[:contents].map{|c| c[:key]}
      end
      contents
    end

    def exists? path
      object     = File.basename(path)
      search_dir = File.dirname(path)
      case search_dir
      when '.' then # only a bucket was passed in
        (full_contents(object).size > 0)
      else
        search_dir_contents = full_contents(search_dir).map{|c| File.basename(c).gsub(/\//, '')}
        search_dir_contents.include?(object)
      end
    end

    def mv srcpath, dstpath
      # @hdfs.rename(Path.new(srcpath), Path.new(dstpath))
    end

    def cp srcpath, dstpath
      # FileUtil.copy(@hdfs, Path.new(srcpath), @hdfs, Path.new(dstpath), false, @conf)
    end

    def mkpath path
      # @hdfs.mkdirs(Path.new(path))
      # path
    end

    def type path
      return "unknown" unless exists? path
      return "directory" if full_contents(path).size > 0
      "file"
    end

    def entries dirpath
      return unless type(dirpath) == "directory"
      full_contents(dirpath)
    end

    def close *args
      # @hdfs.close
    end

    class S3File
      attr_accessor :path, :handle, :hdfs

      #
      # In order to open input and output streams we must pass around the hadoop fs object itself
      #
      def initialize path, mode, fs, &blk
        # @fs   = fs
        # @path = Path.new(path)
        # case mode
        # when "r" then
        #   raise "#{@fs.type(path)} is not a readable file - #{path}" unless @fs.type(path) == "file"
        #   @handle = @fs.hdfs.open(@path).to_io(&blk)
        # when "w" then
        #   # Open path for writing
        #   raise "Path #{path} is a directory." unless (@fs.type(path) == "file") || (@fs.type(path) == "unknown")
        #   @handle = @fs.hdfs.create(@path).to_io.to_outputstream
        #   if block_given?
        #     yield self
        #     self.close # muy muy importante
        #   end
        # end
      end

      def read
        # @handle.read
      end

      def readline
        # @handle.readline
      end

      def write string
        # @handle.write(string.to_java_string.get_bytes)
      end

      def puts string
        # write(string+"\n")
      end

      def close
        # @handle.close
      end

    end

  end

end
