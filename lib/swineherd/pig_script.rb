require 'erubis'
require 'tempfile'
require 'swineherd/hdfs'

#
# Usage: PigScript.new(source, options).run
#

module Swineherd
  
  class PigScript
    attr_accessor :source_template, :pig_options, :run_options

    def initialize source_template, pig_options, run_options = {}
      @pig_options     = pig_options
      @source_template = source_template
      @run_options     = run_options
    end

    def run
      return unless check_outputs(pig_options[:outputs])
      compile!
      execute
    end

    def basename
      File.basename(source_template)
    end

    def compile!
      dest << Erubis::Eruby.new(source).result(pig_options)
      dest << "\n"
      dest
    end

    def run_options
      run_opts = ""
      @run_options.each do |option,value|
        run_opts << "--#{option.to_s}=#{value}"
      end
      run_opts
    end    

    #
    # FIXME: this is nasty, need better local file checking
    #
    def check_outputs outputs
      all_clear = true
      if @run_options[:mode] == 'local'
        outputs.each do |path|
          all_clear = false if File.exist?(path)
        end
      else
        all_clear = Hfile.check_paths(outputs)
      end
      all_clear
    end
    
    #
    # "pigsy.rb" is the superior runner to "pig", put it in your path
    #
    def execute
      dest.read
      system('pigsy.rb', run_options, dest.path)
    end

    protected

    def source
      File.open(source_template).read
    end

    def dest
      return @dest if @dest
      @dest ||= Tempfile.new(basename)
    end
  end
end
