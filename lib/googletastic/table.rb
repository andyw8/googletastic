class Googletastic::Table < Googletastic::Base
  
  attr_accessor :title, :content, :summary, :columns, :spreadsheet_id, :num_rows, :start_row
  
  # Time.now.xmlschema
  class << self
    
    def client_class
      "Spreadsheets"
    end
    
    def show_url(id)
      "http://spreadsheets.google.com/feeds/#{id}/tables"
    end
    
    def build_url(options)
      raise "You must specify an spreadsheet key 'key' for a table" unless options[:key]
      options[:url] ||= show_url(options[:key])
      puts "URL: #{options[:url]}"
      super(options)
    end
    
    def unmarshall(xml)
      records = xml.xpath("//atom:entry", ns_tag("atom")).collect do |record|
        id                = record.xpath("atom:id", ns_tag("atom")).first.text
        spreadsheet_id    = id.gsub("http://spreadsheets.google.com/feeds/([^\/]+)/tables", "\1")
        id                = id.gsub("http://spreadsheets.google.com/feeds/([^\/]+)/tables/([^\/]+)", "\2")
        title             = record.xpath("atom:title", ns_tag("atom")).first.text
        summary           = record.xpath("atom:summary", ns_tag("atom")).first.text
        content           = record.xpath("atom:content", ns_tag("atom")).first.text
        data              = record.xpath("gs:data", ns_tag("gs"))
        num_rows          = data["numRows"].to_i
        start_row         = data["startRow"].to_i
        columns           = []
        data.xpath("gs:column", ns_tag("gs")).each do |column|
          columns << {:name => column["name"], :index => column["index"]}
        end
        columns           = columns.sort {|a,b| b["index"] <=> a["index"]}.collect{|c| c["name"]}
        created_at        = record.xpath("atom:published", ns_tag("atom")).text
        updated_at        = record.xpath("atom:updated", ns_tag("atom")).text
        
        Googletastic::Table.new(
          :id => id,
          :spreadsheet_id => spreadsheet_id,
          :title => title,
          :summary => summary,
          :content => content,
          :start_row => start_row,
          :num_rows => num_rows,
          :columns => columns,
          :updated_at => DateTime.parse(updated_at),
          :raw => record.to_xml
        )
      end
      records
    end
    
  end
end