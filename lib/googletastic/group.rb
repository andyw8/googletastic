class Googletastic::Group < Googletastic::Base
  
  attr_accessor :title, :description, :system_group
  
  class << self
    
    def feed_url
      "http://www.google.com/m8/feeds/groups/default/full"
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
        id            = record.xpath("atom:id", ns_tag("atom")).first.text
        title         = record.xpath("atom:title", ns_tag("atom")).first.text
        description   = record.xpath("atom:content", ns_tag("atom")).first.text
        system_group  = record.xpath("gContact:systemGroup").first
        system_group  = system_group["id"] unless system_group.nil?
        
        Googletastic::Group.new(
          :id => id,
          :title => title,
          :description => description,
          :system_group => system_group
        )
      end
      records
    end
    
  end
  
end