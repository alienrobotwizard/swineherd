require 'pathname'

module Swineherd::Script
  class WukongScript
    include Common
    attr_accessor :input
    def initialize *args
      super(*args)
      @input = []
    end

    def wukong_args options
      options.map{|param,val| "--#{param}=#{val}" }.join(' ')
    end

    def ruby_interpreter_path
      Pathname.new(File.join(
          Config::CONFIG["bindir"],
          Config::CONFIG["RUBY_INSTALL_NAME"]+Config::CONFIG["EXEEXT"])).realpath
    end

    def cmd
      raise "No wukong input specified" if @input.empty?
      "#{ruby_interpreter_path} #{script} #{wukong_args(@options)} --run #{@input.join(',')} #{output.join(',')}"
    end
  end
end
