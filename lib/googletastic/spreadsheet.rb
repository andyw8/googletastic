class Googletastic::Spreadsheet < Googletastic::Base
  
  attr_accessor :title, :content
  
  # Time.now.xmlschema
  class << self
    
    def client_class
      "Spreadsheets"
    end
    
    def index_url
      "http://spreadsheets.google.com/feeds/spreadsheets/private/full"
    end

    def unmarshall(xml)
      records = xml.xpath("//atom:entry", ns_tag("atom")).collect do |record|
        id          = record.xpath("atom:id", ns_tag("atom")).first.text.gsub("http://spreadsheets.google.com/feeds/spreadsheets/", "")
        title       = record.xpath("atom:title", ns_tag("atom")).first.text
        content     = record.xpath("atom:content", ns_tag("atom")).first.text
        created_at  = record.xpath("atom:published", ns_tag("atom")).text
        updated_at  = record.xpath("atom:updated", ns_tag("atom")).text

        Googletastic::Spreadsheet.new(
          :id => id,
          :title => title,
          :content => content,
          :updated_at => DateTime.parse(updated_at)
        )
      end
      records
    end
    
  end
end