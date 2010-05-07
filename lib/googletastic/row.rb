class Googletastic::Row < Googletastic::Base
  
  attr_accessor :data, :worksheet_id, :spreadsheet_id, :title, :etag
  
  def get_url
    self.class.get_url(File.join(self.spreadsheet_id, self.worksheet_id), self.id)
  end
  
  def index_url
    "http://spreadsheets.google.com/feeds/list/#{self.spreadsheet_id}/#{self.worksheet_id}/private/full"
  end
  
  def edit_url
    "http://spreadsheets.google.com/feeds/list/#{self.spreadsheet_id}/#{self.worksheet_id}/private/full/#{self.id}"
  end
  
  # Time.now.xmlschema
  class << self
    
    def client_class
      "Spreadsheets"
    end
    
    def index_url(path)
      "http://spreadsheets.google.com/feeds/list/#{path}/private/full"
    end
    
    def show_url(path, id)
      "http://spreadsheets.google.com/feeds/list/#{path}/private/full/#{id}"
    end
    
    def get_url(path, id)
      "http://spreadsheets.google.com/feeds/list/#{path}/private/full/#{id}"
    end
    
    def build_url(options)
      raise "You must specify a spreadsheet key 'key' and a 'worksheet_id' for a list of rows" unless (options[:key] and options[:worksheet_id])
      options[:url] ||= index_url(File.join(options[:key], options[:worksheet_id]))
      super(options)
    end
    
    def unmarshall(xml)
      records = xml.xpath("//atom:entry", ns_tag("atom")).collect do |record|
        etag              = record["etag"]
        id                = record.xpath("atom:id", ns_tag("atom")).first.text
        ids               = id =~ /http:\/\/spreadsheets\.google\.com\/feeds\/list\/([^\/]+)\/([^\/]+)\/([^\/]+)/
        spreadsheet_id    = $1
        worksheet_id      = $2
        id                = $3
        title             = record.xpath("atom:title", ns_tag("atom")).first.text
        content           = record.xpath("atom:content", ns_tag("atom")).first.text
        created_at        = record.xpath("atom:published", ns_tag("atom")).text
        updated_at        = record.xpath("atom:updated", ns_tag("atom")).text
        data              = {}
        
        record.xpath("gsx:*", ns_tag('gsx')).each do |node|
          next unless node.elem?
          data[node.name] = node.text
        end
        
        Googletastic::Row.new(
          :id => id,
          :etag => etag,
          :title => title,
          :spreadsheet_id => spreadsheet_id,
          :worksheet_id => worksheet_id,
          :data => data,
          :updated_at => DateTime.parse(updated_at),
          :raw => record.to_xml
        )
      end
      records
    end
    
    # for save and update
    def marshall(record)
      Nokogiri::XML::Builder.new { |xml| 
        attributes = nil
        if record.id
          attributes = {"etag" => record.etag}.merge(ns_xml("atom", "gsx"))
        else
          attributes = ns_xml("atom", "gsx")
        end
        xml.entry(attributes) {
          if record.id # PUT = update
            xml.id_ {
              xml.text record.get_url
            }
            #xml.updated {
            #  xml.text record.updated.to_s
            #}
          end
          if record.title
            xml.title(:type => "text") {
              xml.text record.title
            }
          end
          record.data.each do |k,v|
            xml["gsx"].send(k) {
              xml.text v
            }
          end
        }
      }.to_xml
    end
    
  end
end