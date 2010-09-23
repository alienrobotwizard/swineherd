require 'erubis'
require 'tempfile'

#
# Usage: RScript.new(source, options).run
#

module Swineherd

  class RScript
    attr_accessor :source_template, :r_options

    def initialize source_template, r_options
      @r_options       = r_options
      @source_template = source_template
    end

    def run
      return unless check_outputs(r_options[:outputs])
      compile!
      execute
    end

    def basename
      File.basename(source_template)
    end

    def compile!
      dest << Erubis::Eruby.new(source).result(r_options)
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
      outputs.each do |path|
        all_clear = false if File.exist?(path)
      end
      all_clear
    end

    #
    # "pigsy.rb" is the superior runner to "pig", put it in your path
    #
    def execute
      dest.read
      # system('echo', 'Rscript --vanilla', dest.path)
      exec('/usr/bin/Rscript', '--vanilla', dest.path)
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
