require 'erubis'
require 'tempfile'


# Template.new(script_path, attributes).substitute!

module Swineherd

  class Template
    attr_accessor :source_template, :attributes

    def initialize source_template, attributes
      @source_template = source_template
      @attributes      = attributes
    end

    def compile!
      dest << Erubis::Eruby.new(source).result(attributes)
      dest << "\n"
      dest
    end

    def substitute!
      compile!
      dest.read
      dest.path
    end

    protected

    def source
      File.open(source_template).read
    end

    def dest
      return @dest if @dest
      @dest ||= Tempfile.new(basename)
    end

    def basename
      File.basename(source_template)
    end

  end
end
