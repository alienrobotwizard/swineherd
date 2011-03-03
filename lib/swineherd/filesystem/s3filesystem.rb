require 'tempfile'
module Swineherd

  #
  # Methods for interacting with Amazon's Simple Store Service (s3).
  #
  class S3FileSystem

    include Swineherd::BaseFileSystem

    attr_accessor :s3

    #
    # Initialize a new s3 file system, needs path to aws keys
    #
    def initialize aws_access_key_id, aws_secret_access_key
      require 'right_aws'
      @s3 = RightAws::S3.new(aws_access_key_id, aws_secret_access_key)
    end

    def open path, mode="r", &blk
      S3File.new(path,mode,self,&blk)
    end

    def rm path
      bkt = bucket(path)
      key = key_path(path)
      if key.empty? # only the bucket was passed in, delete it
        @s3.interface.force_delete_bucket(bkt)
      else
        case type(path)
        when "directory" then
          keys_to_delete = lr(path)
          keys_to_delete.each do |k|
            key_to_delete = key_path(k)
            @s3.interface.delete(bkt, key_to_delete)
          end
          keys_to_delete
        when "file" then
          @s3.interface.delete(bkt, key)
          [path]
        end
      end
    end

    def bucket path
      uri = URI.parse(path)
      uri.path.split('/').reject{|x| x.empty?}.first
    end

    def key_path path
      uri = URI.parse(path)
      File.join(uri.path.split('/').reject{|x| x.empty?}[1..-1])
    end

    def needs_trailing_slash pre
      has_trailing_slash = pre.end_with? '/'
      is_empty_prefix    = pre.empty?
      !(has_trailing_slash || is_empty_prefix)
    end

    def full_contents path
      bkt = bucket(path)
      pre = key_path(path)
      pre += '/' if needs_trailing_slash(pre)
      contents = []
      s3.interface.incrementally_list_bucket(bkt, {'prefix' => pre, 'delimiter' => '/'}) do |res|
        contents += res[:common_prefixes].map{|c| File.join(bkt,c)}
        contents += res[:contents].map{|c| File.join(bkt, c[:key])}
      end
      contents
    end

    def exists? path
      object     = File.basename(path)
      search_dir = File.dirname(path)
      case search_dir
      when '.' then # only a bucket was passed in
        begin
          (full_contents(object).size > 0)
        rescue RightAws::AwsError => e
          if e.message =~ /nosuchbucket/i
            false
          else
            raise e
          end
        end
      else
        search_dir_contents = full_contents(search_dir).map{|c| File.basename(c).gsub(/\//, '')}
        search_dir_contents.include?(object)
      end
    end

    def mv srcpath, dstpath
      src_bucket   = bucket(srcpath)
      dst_bucket   = bucket(dstpath)
      dst_key_path = key_path(dstpath)
      mkpath(dstpath)
      case type(srcpath)
      when "directory" then
        paths_to_copy = lr(srcpath)
        common_dir    = common_directory(paths_to_copy)
        paths_to_copy.each do |path|
          src_key = key_path(path)
          dst_key = File.join(dst_key_path, path.gsub(common_dir, ''))
          @s3.interface.move(src_bucket, src_key, dst_bucket, dst_key)
        end
      when "file" then
        @s3.interface.move(src_bucket, key_path(srcpath), dst_bucket, dst_key_path)
      end
    end

    def cp srcpath, dstpath
      src_bucket   = bucket(srcpath)
      dst_bucket   = bucket(dstpath)
      dst_key_path = key_path(dstpath)
      mkpath(dstpath)
      case type(srcpath)
      when "directory" then
        paths_to_copy = lr(srcpath)
        common_dir    = common_directory(paths_to_copy)
        paths_to_copy.each do |path|
          src_key = key_path(path)
          dst_key = File.join(dst_key_path, path.gsub(common_dir, ''))
          @s3.interface.copy(src_bucket, src_key, dst_bucket, dst_key)
        end
      when "file" then
        @s3.interface.copy(src_bucket, key_path(srcpath), dst_bucket, dst_key_path)
      end
    end

    #
    # This is a bit funny, there's actually no need to create a 'path' since
    # s3 is nothing more than a glorified key-value store. When you create a
    # 'file' (key) the 'path' will be created for you. All we do here is create
    # the bucket unless it already exists.
    #
    def mkpath path
      bkt = bucket(path)
      key = key_path(path)
      if key.empty?
        @s3.interface.create_bucket(bkt)
      else
        @s3.interface.create_bucket(bkt) unless exists? bkt
      end
      path
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

    # Recursively list paths
    def lr path
      paths = entries(path)
      if paths
        paths.map{|e| lr(e)}.flatten
      else
        path
      end
    end

    #
    # Ick.
    #
    def common_directory paths
      dirs     = paths.map{|path| path.split('/')}
      min_size = dirs.map{|splits| splits.size}.min
      dirs.map!{|splits| splits[0...min_size]}
      uncommon_idx = dirs.transpose.each_with_index.find{|dirnames, idx| dirnames.uniq.length > 1}.last
      dirs[0][0...uncommon_idx].join('/')
    end

    def close *args
    end

    class S3File
      attr_accessor :path, :handle, :fs

      #
      # In order to open input and output streams we must pass around the s3 fs object itself
      #
      def initialize path, mode, fs, &blk
        @fs   = fs
        @path = path
        case mode
        when "r" then
          raise "#{fs.type(path)} is not a readable file - #{path}" unless fs.type(path) == "file"
        when "w" then
          raise "Path #{path} is a directory." unless (fs.type(path) == "file") || (fs.type(path) == "unknown")
          @handle = Tempfile.new('s3filestream')
          if block_given?
            yield self
            close
          end
        end
      end

      #
      # Faster than iterating
      #
      def read
        resp = fs.s3.interface.get_object(fs.bucket(path), fs.key_path(path))
        resp
      end

      #
      # This is a little hackety. That is, once you call (.each) on the object the full object starts
      # downloading...
      #
      def readline
        @handle ||= fs.s3.interface.get_object(fs.bucket(path), fs.key_path(path)).each        
        begin
          @handle.next
        rescue StopIteration, NoMethodError
          @handle = nil
          raise EOFError.new("end of file reached")
        end
      end

      def write string
        @handle.write(string)
      end

      def puts string
        write(string+"\n")
      end

      def close
        if @handle
          @handle.read
          fs.s3.interface.put(fs.bucket(path), fs.key_path(path), File.open(@handle.path, 'r'))
          @handle.close
        end
        @handle = nil
      end

    end

  end

end
