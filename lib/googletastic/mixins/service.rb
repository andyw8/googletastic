module Googletastic::Mixins::Service
  
  def self.included(base)
    base.extend(ClassMethods)
  end
  
  module ClassMethods

    def urlify(url, params = {})
      if params && !params.empty?
        query = params.collect do |k,v|
          v = v.to_json if %w{key startkey endkey}.include?(k.to_s)
          "#{k}=#{CGI.escape(v.to_s)}"
        end.join("&")
        url = "#{url}?#{query}"
      end
      url
    end
    
    def feed_url
      raise "Override Me in Subclasses!"
    end

    # helper method for google client
    def client(name = self.client_class)
      Googletastic.client_for(name.to_s.underscore)
    end
    
    def build_url(options)
      base = options.has_key?(:url) ? options[:url] : self.feed_url
      options[:url] = base
      urlify(base, extract_params(options))
    end
    
    # implement in subclasses
    def unmarshall(xml_records)
      raise "Implemnent in subclasses"
    end
    
    # implement in subclasses
    def marshall(records)
      raise "Implemnent in subclasses"
    end
    
    # http://code.google.com/apis/gdata/docs/2.0/reference.html#Queries
    def extract_params(options)
      options.inject({}) do |converted, (key, value)|
        converted[self.valid_queries[key]] = value if self.valid_queries.has_key?(key)
        converted
      end
    end
  end
end