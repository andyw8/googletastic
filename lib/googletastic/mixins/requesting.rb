module Googletastic::Mixins::Requesting
  
  def self.included(base)
    base.extend(ClassMethods)
    base.class_eval do
      include InstanceMethods
    end
  end
  
  module ClassMethods
    
    def valid_queries
      {
        :limit => "max-result",
        :offset => "start-index",
        :start => "start-index",
        :end => "end-index",
        :categories => "category",
        :with => "q"
#        :only => "fields", # only the fields we want!
#        :fields => "fields"
      }
    end
    
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

    # helper method for google client
    def client(name = self.client_class)
      Googletastic.client_for(name.to_s.underscore)
    end
    
    def build_url(options)
      base = options.has_key?(:url) ? options[:url] : self.index_url
      options[:url] = base
      urlify(base, extract_params(options))
    end
    
    # http://code.google.com/apis/gdata/docs/2.0/reference.html#Queries
    def extract_params(options)
      queries = self.valid_queries
      options.inject({}) do |converted, (key, value)|
        real_key = queries[key]
        if queries.has_key?(key)
          next if self.respond_to?("valid_#{real_key}?") and !self["valid_#{real_key}?"]
          value = self.send("convert_#{real_key}", value) if self.respond_to?("convert_#{real_key}")
          converted[real_key] = value
        end
        converted
      end
    end
    
    # http://code.google.com/apis/gdata/docs/2.0/reference.html#PartialResponse
    # link,entry(@gd:etag,id,updated,link[@rel='edit']))
    # fields=entry[author/name='Lance']
    def convert_fields(value)
      value
    end
  end
  
  module InstanceMethods

    def has_attachment?
      !self.attachment_path.nil?
    end
    
    def mime_type
      return "" if has_attachment?
      return "" #TODO
    end
  end
end