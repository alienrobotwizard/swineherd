#!/usr/bin/env ruby

#
# These tests cannot possibly pass unless you have an amazon account with proper
# credentials. Furthermore, you definitely want a test bucket to play with. In
# this set of mock tests I've called it 'test-bucket' which will certainly get
# you and 'access-denied' error. Also, despite all that, 4 tests (see below)
# will fail outright.
#
# This one has to break the rules slightly because amazon-s3 is not actually a
# filesystem implementation. There's no such thing as a 'path' and so the following
# tests will fail:
#
# 1. it "should be able to create a path" (path wont exist but it's ok, thats what
# we expect)
#
# 2. it "should be able to copy paths" (it can't create paths that aren't files
# and so we expect this to fail, again it's ok.)
#
# 3. it "should be able to move paths" (it can't create paths that aren't files
# and so we expect this to fail, again it's ok.)
#
# 4. it "can return an array of directory entries" (ditto)
#
# Note: If one were to rewrite the above tests to use existing paths on s3 then the
# tests will succeed. Try it.
#


$LOAD_PATH << 'lib'
require 'swineherd/filesystem' ; include Swineherd
require 'rubygems'
require 'yaml'
require 'rspec'

options = YAML.load(File.read(File.dirname(__FILE__)+'/testcfg.yaml'))
current_test = 's3'
describe "A new filesystem" do

  before do
    @test_path   = "#{options['s3_test_bucket']}/tmp/rspec/test_path"
    @test_path2  = "#{options['s3_test_bucket']}/tmp/rspec/test_path2"
    @test_string = "@('_')@"     
    @fs = Swineherd::FileSystem.get(current_test, options['aws_access_key_id'], options['aws_secret_access_key'])
  end

  it "should implement exists?" do
    [true, false].should include(@fs.exists?(@test_path))
  end

  it "should be able to create a path" do
    @fs.mkpath(@test_path)
    @fs.exists?(@test_path).should eql(true)
  end

  it "should be able to remove a path" do
    @fs.mkpath(@test_path)
    @fs.rm(@test_path)
    @fs.exists?(@test_path).should eql(false)
  end

  it "should implement size" do
    @fs.mkpath(File.dirname(@test_path))
    fileobj = @fs.open(@test_path, 'w')
    fileobj.write(@test_string)
    fileobj.close
    7.should eql(@fs.size(@test_path))
    @fs.rm(@test_path)
    @fs.rm(File.dirname(@test_path))
  end

  it "should be able to copy paths" do
    @fs.mkpath(@test_path)
    @fs.cp(@test_path, @test_path2)
    @fs.exists?(@test_path2).should eql(true)
    @fs.rm(@test_path)
    @fs.rm(@test_path2)
  end

  it "should be able to move paths" do
    @fs.mkpath(@test_path)
    @fs.mv(@test_path, @test_path2)
    @fs.exists?(@test_path).should eql(false)
    @fs.exists?(@test_path2).should eql(true)
    @fs.rm(@test_path2)
  end

  it "should return a sane path type" do
    @fs.mkpath(@test_path)
    ["file", "directory", "symlink", "unknown"].should include(@fs.type(@test_path))
    @fs.rm(@test_path)
  end

  it "can return an array of directory entries" do
    sub_paths = ["a", "b", "c"]
    sub_paths.each do |sub_path|
      @fs.mkpath(File.join(@test_path, sub_path))
    end
    @fs.entries(@test_path).class.should eql(Array)
    @fs.entries(@test_path).map{|path| File.basename(path)}.reject{|x| x =~ /\./}.sort.should eql(sub_paths.sort)
    @fs.rm(@test_path)
  end

  it "can answer to open with a writable file object" do
    fileobj = @fs.open(@test_path, 'w')
    fileobj.should respond_to :write
    @fs.rm(@test_path)
  end

end

describe "A new file" do
  before do
    @test_path   = "#{options['s3_test_bucket']}/tmp/rspec/test_path"
    @test_path2  = "#{options['s3_test_bucket']}/test_path2"
    @test_string = "@('_')@"
    @fs = Swineherd::FileSystem.get(current_test, options['aws_access_key_id'], options['aws_secret_access_key'])
  end

  it "should be closeable" do
    @fs.open(@test_path, 'w').close
  end

  it "should be writeable" do
    fileobj = @fs.open(@test_path, 'w')
    fileobj.write(@test_string)
    fileobj.close
    @fs.rm(@test_path)
  end

  it "should be readable" do

    fileobjw = @fs.open(@test_path, 'w')
    fileobjw.write(@test_string)
    fileobjw.close

    fileobjr = @fs.open(@test_path, 'r')
    fileobjr.read.should eql(@test_string)

    @fs.rm(@test_path)
  end

end
