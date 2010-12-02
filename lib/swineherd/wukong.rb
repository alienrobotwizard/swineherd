require 'pathname'

module Swineherd
  class Wukong

    def self.wukong_args options
      options.map{|param,val| "--#{param}=#{val}" }.join(' ')
    end

    def self.ruby_interpreter_path
      Pathname.new(File.join(
          Config::CONFIG["bindir"],
          Config::CONFIG["RUBY_INSTALL_NAME"]+Config::CONFIG["EXEEXT"])).realpath
    end

    def self.cmd(script, args, inputs, output)
      "#{ruby_interpreter_path} #{script} #{wukong_args(args)} --run #{inputs} #{output}"
    end

  end
end
