module Googletastic::Api
  
  class << self
    
    def sync(documents, options = {}, &block)
      updated = Googletastic::Api::Sync.process_documents(documents, options)
      options[:key] ||= "documents"
      key = options[:key].to_s
      data = {key => []}
      updated_documents.each do |document|
        data[key] << document.remote.id
        yield(data, key, document) if block_given?
      end
      response = Googletastic::Api::Sync.post(
        :url => options[:url],
        :path => options[:path],
        :format => :json,
        :data => data
      )
    end
    
  end
  
end

require_local "mixins/*", __FILE__