class Googletastic::Person < Googletastic::Base
  
  attr_accessor :name, :email
  
  class << self
    
    def feed_url
      "http://www.google.com/m8/feeds/contacts/default/full"
    end
    
    def client_class
      "Contacts"
    end
    
    # http://code.google.com/apis/contacts/docs/2.0/reference.html#Parameters
    def valid_queries
      {
        :order => "orderby",
        :sort => "sortorder",
        :group => "group"
      }.merge(super)
    end
    
    def unmarshall(xml)
      records = xml.xpath("//atom:entry", ns_tag("atom")).collect do |record|
        id      = record.xpath("atom:id", ns_tag("atom")).first.text
        name    = record.xpath("atom:title", ns_tag("atom")).first.text
        email   = record.xpath("gd:email", ns_tag("gd")).first["address"].to_s
        
        Googletastic::Person.new(
          :id => id,
          :name => name,
          :email => email
        )
      end
      records
    end
    
  end
  
end