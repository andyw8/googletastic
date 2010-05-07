class Googletastic::Spreadsheet < Googletastic::Base
  
  attr_accessor :title, :content, :edit_id
  
  def worksheet_url
    self.class.worksheet_url(self.id)
  end
  
  def worksheet
    @worksheet ||= Googletastic::Worksheet.first(:key => self.id)
  end
  
  def table
    @table ||= Googletastic::Table.first(:key => self.id)
  end
  
  def rows
    @rows ||= Googletastic::Row.all(:key => self.id, :worksheet_id => worksheet.id)
  end
  
  # Time.now.xmlschema
  class << self
    
    def client_class
      "Spreadsheets"
    end
    
    def index_url
      "http://spreadsheets.google.com/feeds/spreadsheets/private/full"
    end
    
    def worksheet_url(id)
      "http://spreadsheets.google.com/feeds/worksheets/#{id}/private/full"
    end

    def unmarshall(xml)
      records = xml.xpath("//atom:entry", ns_tag("atom")).collect do |record|
        id          = record.xpath("atom:id", ns_tag("atom")).first.text.gsub("http://spreadsheets.google.com/feeds/spreadsheets/", "")
        edit_id           = record.xpath("atom:link[@rel='alternate']", ns_tag("atom")).first
        edit_id           = edit_id["href"].gsub("http://spreadsheets.google.com/ccc?key=", "") if edit_id
        title             = record.xpath("atom:title", ns_tag("atom")).first.text
        content           = record.xpath("atom:content", ns_tag("atom")).first.text
        created_at        = record.xpath("atom:published", ns_tag("atom")).text
        updated_at        = record.xpath("atom:updated", ns_tag("atom")).text
        
        Googletastic::Spreadsheet.new(
          :id => id,
          :edit_id => edit_id,
          :title => title,
          :content => content,
          :updated_at => DateTime.parse(updated_at),
          :raw => record.to_xml
        )
      end
      records
    end
    
  end
end