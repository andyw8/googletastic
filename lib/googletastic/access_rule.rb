class Googletastic::AccessRule < Googletastic::Base
  
  attr_accessor :title, :agent, :role, :email
  
  class << self
    
    def build_url(options)
      base = nil
      if options.has_key?(:document_id)
        options[:client] = Googletastic::Document.client
        base = "http://docs.google.com/feeds/acl/private/full/#{options[:document_id]}"
      end
      options[:url] = base
      super(options)
    end
    
    def unmarshall(xml)
      records = xml.xpath("//atom:entry", ns_tag("atom")).collect do |record|
        title = id = value = nil # reset
        id          = record.xpath("atom:id", ns_tag("atom")).text
        title       = record.xpath("atom:title", ns_tag("atom")).text
        scope       = record.xpath("gAcl:scope", ns_tag("gAcl")).first
        role        = record.xpath("gAcl:role", ns_tag("gAcl")).first["value"].to_s
        Googletastic::AccessRule.new(
          :id => id,
          :title => title,
          :email => scope["value"].to_s,
          :agent => scope["type"].to_s,
          :role => role
        )
      end
      records
    end
    
    def marshall(record)
      
    end
    
  end
  
  def has_access?(email)
    self.email == email
  end
  
end