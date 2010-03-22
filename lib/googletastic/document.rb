class Googletastic::Document < Googletastic::Base
  
  ID = "https://docs.google.com/feeds/default/private/full/document%3A"
  FEED_BASE = 'http://docs.google.com/feeds' unless defined?(FEED_BASE)
  FEED = 'http://docs.google.com/feeds/documents/private/full' unless defined?(FEED)
  BASE_URL = "http://docs.google.com" unless defined?(BASE_URL)
  DOCS_DOWNLOAD = 'download/documents/Export'
  CSV = "text/csv" unless defined?(CSV)
  TSV = "text/tab-separated-values" unless defined?(TSV)
  TAB = "text/tab-separated-values" unless defined?(TAB)
  HTML = "text/html" unless defined?(HTML)
  HTM = "text/html" unless defined?(HTM)
  DOC = "application/msword" unless defined?(DOC)
  DOCX = "application/vnd.openxmlformats-officedocument.wordprocessingml.document" unless defined?(DOCX)
  ODS = "application/x-vnd.oasis.opendocument.spreadsheet" unless defined?(ODS)
  ODT = "application/vnd.oasis.opendocument.text" unless defined?(ODT)
  RTF = "application/rtf" unless defined?(RTF)
  SXW = "application/vnd.sun.xml.writer" unless defined?(SXW)
  TXT = "text/plain" unless defined?(TXT)
  XLS = "application/vnd.ms-excel" unless defined?(XLS)
  XLSX = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" unless defined?(XLSX)
  PDF = "application/pdf" unless defined?(PDF)
  PPT = "application/vnd.ms-powerpoint" unless defined?(PPT)
  PPS = "application/vnd.ms-powerpoint" unless defined?(PPS)
  
  attr_accessor :title, :kind, :categories
  
  def view_url
    "http://docs.google.com/View?docID=#{id}&revision=_latest"
  end
  
  def download_url(format = "pdf")
    "#{FEED_BASE}/download/documents/Export?docID=#{id}&exportFormat=#{format}"
  end
  
  def edit_url
    "#{BASE_URL}/Doc?docid=#{id}"
  end
  
  def self.feed_url
    "#{FEED}"
  end
  
  attr_reader :body
  def body
    return @body if @body
    @body = client.get(self.view_url).to_xml
  end
  
  attr_reader :content
  # returns the content within the body tags for the document
  def content
    return @content if @content
    body.xpath("//img").each do |img_node|
      if img_node["src"] =~ /File\?/
        img_node["src"] = "#{BASE_URL}/#{img_node['src']}"
      end
    end
    body.xpath("//div[@id='google-view-footer']").each { |n| n.unlink }
    @content = body.xpath("//div[@id='doc-contents']").first
  end
  
  def acl
    return @acl if @acl
    @acl = Googletastic::AccessRule.find(:all, :document_id => id)
  end
  
  # returns the styles for the document, in case you need them
  def styles
    
  end
  
  def new_record?
    return false if !self.id.nil?
    return self.class.first(:title => self.title, :exact_title => true).nil?
  end
  
  # Time.now.xmlschema
  class << self
    VALID_CATEGORIES = /^(document|spreadsheet|folder|presentation|pdf|form)$/ unless defined?(VALID_CATEGORIES)
    
    def valid_queries
      {
        :title => "title",
        :exact_title => "title-exact",
        :opened_after => "opened-min",
        :opened_before => "opened-max",
        :edited_after => "edited-min",
        :edited_before => "edited-max",
        :owner => "owner",
        :writer => "writer",
        :reader => "reader",
        :show_folders => "showfolders",
        :show_deleted => "showdeleted",
        :optical_character_recognition => "ocr",
        :translate_to => "targetLanguage",
        :language => "sourceLanguage",
        :permanent_delete => "delete",
        :convert => "convert"
      }.merge(super)
    end
    
    def client_class
      "DocList"
    end
    
    def build_url(options)
      base = options.has_key?(:url) ? options[:url] : self.feed_url
      if options.has_key?(:include)
        if options[:include].index(:acl)
          base.gsub!(/full$/, "expandAcl")
        end
      end
      if options.has_key?(:id)
        base << "/#{options[:id]}"
      end
      options[:url] = base
      super(options)
    end
    
    def unmarshall(xml)
      records = xml.xpath("//atom:entry", ns_tag("atom")).collect do |record|
        kind = title = id = categories = value = nil # reset
        title       = record.xpath("atom:title", ns_tag("atom")).text
        id          = record.xpath("gd:resourceId", ns_tag("gd")).text
        categories  = []
        record.xpath("atom:category", ns_tag("atom")).each do |category|
          value = category["label"].to_s
          categories << value
          if !kind and value =~ VALID_CATEGORIES
            kind = $1
          end
        end
        Googletastic::Document.new(
          :id => id,
          :title => title,
          :categories => categories,
          :kind => kind
        )
      end
      records
    end
    
    def marshall(record)
      Nokogiri::XML::Builder.new { |xml| 
        xml.entry(ns_xml("atom", "exif", "media", "gphoto", "openSearch")) {
          if record.id
            xml.id {
              xml.text "#{ID}#{record.id}"
            }
          end
          record.categories.each do |category|
#            xml.category(
#              :scheme => "http://schemas.google.com/g/2005#kind",
#              :term => "#{DOCS_NS}##{category}"
#            )
          end
          xml.title {
            xml.text record.title
          }
        }
      }.to_xml
    end
  end
end