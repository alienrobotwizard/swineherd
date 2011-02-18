require 'pathname'

module Swineherd::Script
  class WukongScript
    include Common

    def wukong_args options
      options.map{|param,val| "--#{param}=#{val}" }.join(' ')
    end

    def ruby_interpreter_path
      Pathname.new(File.join(
          Config::CONFIG["bindir"],
          Config::CONFIG["RUBY_INSTALL_NAME"]+Config::CONFIG["EXEEXT"])).realpath
    end

    def cmd
      raise "No wukong input specified" if input.empty?
      "#{ruby_interpreter_path} #{script} #{wukong_args(@options)} --run #{input.join(',')} #{output.join(',')}"
    end

    # FIXME: wukong's local mode doesn't work?
    def local_cmd
      inputs = input.map{|path| path += "/*"}.join(',')
      "#{ruby_interpreter_path} #{script} #{wukong_args(@options)} --run=local #{inputs} #{output.join(',')}"
    end

  end
end
