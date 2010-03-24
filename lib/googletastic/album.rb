class Googletastic::Album < Googletastic::Base
  
  class << self
    
    def client_class
      "Photos"
    end
    
    def index_url
      "http://picasaweb.google.com/data/feed/api/user/default"
    end
    
    def unmarshall(xml)
      records = xml.xpath("//atom:entry", ns_tag("atom")).collect do |record|
        
      end
      records
    end
    
  end
  
end