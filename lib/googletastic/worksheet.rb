class Googletastic::Worksheet < Googletastic::Base
  
  attr_accessor :title, :content, :spreadsheet_id
  
  # Time.now.xmlschema
  class << self
    
    def client_class
      "Spreadsheets"
    end
    
    def show_url(id)
      "http://spreadsheets.google.com/feeds/worksheets/#{id}/private/full"
    end
    
    def build_url(options)
      raise "You must specify an spreadsheet key 'key' for a worksheet" unless options[:key]
      options[:url] ||= show_url(options[:key])
      super(options)
    end
    
    def unmarshall(xml)
      records = xml.xpath("//atom:entry", ns_tag("atom")).collect do |record|
        id                = record.xpath("atom:id", ns_tag("atom")).first.text
        ids               = id =~ /http:\/\/spreadsheets\.google\.com\/feeds\/worksheets\/([^\/]+)\/([^\/]+)/
        spreadsheet_id    = $1
        id                = $2
        title             = record.xpath("atom:title", ns_tag("atom")).first.text
        content           = record.xpath("atom:content", ns_tag("atom")).first.text
        updated_at        = record.xpath("atom:updated", ns_tag("atom")).text
        
        worksheet = Googletastic::Worksheet.new(
          :id => id,
          :spreadsheet_id => spreadsheet_id,
          :title => title,
          :content => content,
          :updated_at => DateTime.parse(updated_at),
          :raw => record.to_xml
        )

        worksheet
      end
      records
    end
    
  end
end