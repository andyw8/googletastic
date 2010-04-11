# "Anonymous modules have no name to be referenced by"
#   If you have a class constant that's undefined
class Googletastic::Document < Googletastic::Base
  
  ID = "https://docs.google.com/feeds/default/private/full/"
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
  
  attr_accessor :title, :kind, :categories, :resource_id, :ext
  
  def has_access?(email)
    self.class.first(:url => update_url)
  end
  
  attr_reader :body
  def body
    return @body if @body
    @body = Nokogiri::XML(view.body)
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
  
  def view
    client.get(self.show_url)
  end
  
  def download(format = "pdf")
    client.get(self.download_url + "&exportFormat=#{format}")
  end
  
  def new_record?
    return false if !self.id.nil?
    return self.class.first(:title => self.title, :exact_title => true).nil?
  end
  
  # Time.now.xmlschema
  class << self
    
    def client_class
      "DocList"
    end
    
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
        :convert => "convert",
        :format => "exportFormat"
      }.merge(super)
    end
    
    def valid_category?(value)
      %w(document spreadsheet folder presentation pdf form).include?(value)
    end
    
    def index_url(ids = nil)
      "http://docs.google.com/feeds/documents/private/full"
    end
    
    # docid (all lowercase)
    def show_url(id)
      "http://docs.google.com/View?docID=#{id}&revision=_latest"
    end
    
    def get_url(id)
      "https://docs.google.com/feeds/default/private/full/#{id}"
    end
    
    def edit_url(id)
      "http://docs.google.com/Doc?docid=#{id}"
    end
    
    def update_url(id)
      if has_attachment?
        "http://docs.google.com/feeds/media/private/full/#{self.id}"
      else
        "http://docs.google.com/feeds/documents/private/full/#{self.id}"
      end
    end

    # docId (camelcase)
    def download_url(id)
      "http://docs.google.com/feeds/download/documents/Export?docId=#{id}"
    end
    
    def upload_url(id = nil)
      index_url(id)
    end
    
    %w(document spreadsheet folder presentation pdf form).each do |category|
      define_method category do
        all(:url => "#{index_url}/-/#{category}")
      end
    end
    
    def download(*args)
      old_options = args.extract_options!
      options = {}
      options[:format] = old_options[:format] || "pdf"
      options[:url] = download_url(args.first.is_a?(String) ? args.first : old_options[:id])
      args << options
      find(*args)
    end
    
    def upload(*args)
      client.post_file(upload_url, args.first, TXT)
    end
    
    def build_url(options)
      base = options.has_key?(:url) ? options[:url] : self.index_url
      base.gsub!(/full$/, "expandAcl") if options.has_key?(:include) and options[:include].index(:acl)
      base << "/#{options[:id]}" if options.has_key?(:id)
      options[:url] = base
      super(options)
    end
    
    def unmarshall(xml)
      records = xml.xpath("//atom:entry", ns_tag("atom")).collect do |record|
        kind = title = id = categories = value = nil # reset
        title       = record.xpath("atom:title", ns_tag("atom")).text
        categories  = record.xpath("atom:category", ns_tag("atom")).collect do |category|
          value = category["label"].to_s
          kind = value if !kind and valid_category?(value)
          value
        end
        resource_id = record.xpath("gd:resourceId", ns_tag("gd")).text
        id          = resource_id.gsub(/#{kind}:/, "")
        created_at  = record.xpath("atom:published", ns_tag("atom")).text
        updated_at  = record.xpath("atom:updated", ns_tag("atom")).text
        puts "UPDATED AT: #{updated_at.inspect}"
        Googletastic::Document.new(
          :id => id,
          :title => title,
          :categories => categories,
          :kind => kind,
          :resource_id => resource_id,
          :ext => File.extname(title),
          :created_at => DateTime.parse(created_at),
          :updated_at => DateTime.parse(updated_at)
        )
      end
      records
    end
    
    def marshall(record)
      Nokogiri::XML::Builder.new { |xml| 
        xml.entry(ns_xml("atom", "exif", "openSearch")) {
          if record.id
            xml.id_ {
              xml.text get_url(record.resource_id)
            }
          end
          record.categories.each do |category|
            xml.category(
              :scheme => "http://schemas.google.com/g/2005#kind",
              :term => "#{category}"
            )
          end
          xml.title {
            xml.text record.title
          }
        }
      }.to_xml
    end
  end
end