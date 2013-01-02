require 'zip/zip'
require 'rocx/parts/core_part'
require 'rocx/parts/document_part'
require 'rocx/parts/app_part'
require 'rocx/parts/content_types_part'
require 'rocx/parts/web_settings_part'
require 'rocx/parts/relationships_part'

module Rocx
  class Document
    
    attr_accessor :document, :core, :app, :content_types, :web_settings, :relationships
    
    def initialize(&block)
      @core = nil
      @document = nil
      @app = AppPart.new
      @content_types = ContentTypesPart.new
      @web_settings = WebSettingsPart.new
      @relationships = [
        ['http://schemas.openxmlformats.org/officeDocument/2006/relationships/numbering','numbering.xml'],
        ['http://schemas.openxmlformats.org/officeDocument/2006/relationships/styles','styles.xml'],
        ['http://schemas.openxmlformats.org/officeDocument/2006/relationships/settings','settings.xml'],
        ['http://schemas.openxmlformats.org/officeDocument/2006/relationships/webSettings','webSettings.xml'],
        ['http://schemas.openxmlformats.org/officeDocument/2006/relationships/fontTable','fontTable.xml'],
        ['http://schemas.openxmlformats.org/officeDocument/2006/relationships/theme','theme/theme1.xml']
      ]
      
      instance_eval &block if block_given?
      
      meta_data if @core.nil?
      @relationships = RelationshipsPart.new @relationships
    end
    
    def meta_data(options={})
      @core = CorePart.new(options)
    end
    
    def body(&block)
      @document = DocumentPart.new(&block)
    end
    
    def save(path)
      parts_to_write = [@core, @document, @app, @content_types, @web_settings, @relationships]
      
      Zip::ZipFile.open(path, Zip::ZipFile::CREATE) do |zipfile|
        Dir.chdir(File.expand_path(File.dirname(__FILE__) + "/../data/template/"))
        Dir.glob('**/*') { |a| zipfile.add(a, a) if File.file?(a) }
        
        parts_to_write.each do |part|
          part.to_xml
          temp = Tempfile.new('part')
          temp.write part.to_s
          temp.rewind
          zipfile.add part.path, temp.path
          temp.close
          temp.unlink
        end
      end
    end
    
  end
end
