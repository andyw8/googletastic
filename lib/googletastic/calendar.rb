class Googletastic::Calendar < Googletastic::Base
  
  attr_accessor :created_at, :updated_at, :title, :role
  attr_accessor :color, :hidden, :selected, :timezone
  
  class << self
    
    def feed_url
      "http://www.google.com/calendar/feeds/default/allcalendars/full"
    end
    
    def build_url(options)
      base = options.has_key?(:url) ? options[:url] : self.feed_url
      options[:url] = base
      super(options)
    end
    
    def unmarshall(xml)
      records = xml.xpath("//atom:entry", ns_tag("atom")).collect do |record|
        id          = record.xpath("atom:id", ns_tag("atom")).first.text
        title       = record.xpath("atom:title", ns_tag("atom")).first.text
        created_at  = record.xpath("atom:published", ns_tag("atom")).first.text
        updated_at  = record.xpath("atom:updated", ns_tag("atom")).first.text
        
        role        = record.xpath("gCal:accesslevel", ns_tag("gCal")).first["value"]
        color       = record.xpath("gCal:color", ns_tag("gCal")).first["value"]
        hidden      = record.xpath("gCal:hidden", ns_tag("gCal")).first["value"]
        selected    = record.xpath("gCal:selected", ns_tag("gCal")).first["value"]
        timezone    = record.xpath("gCal:timezone", ns_tag("gCal")).first["value"]
        
        Googletastic::Calendar.new(
          :id => id,
          :title => title,
          :created_at => created_at,
          :updated_at => updated_at,
          :role => role,
          :color => color,
          :selected => selected,
          :timezone => timezone
        )
      end
      records
    end
    
    def marshall(record)
      Nokogiri::XML::Builder.new { |xml| 
        xml.entry(ns_xml("atom", "gCal")) {
          if record.id
            xml.id {
              xml.text "#{ID}#{record.id}"
            }
          end
          xml.title {
            xml.text record.title
          }
        }
      }.to_xml
    end
    
  end

end