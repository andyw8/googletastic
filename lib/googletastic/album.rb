class Googletastic::Album < Googletastic::Base
  
  class << self
    
    def client_class
      "Photos"
    end
    
    def feed_url
      "http://picasaweb.google.com/data/feed/api/user/default"
    end
    
    def build_url(options)
      base = options.has_key?(:url) ? options[:url] : self.feed_url
      options[:url] = base
      super(options)
    end
    
    def unmarshall(xml)
      records = xml.xpath("//atom:entry", ns_tag("atom")).collect do |record|
        
      end
      records
    end
    
  end
  
end