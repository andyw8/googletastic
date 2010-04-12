module Googletastic::Sync
  
  class << self
    
    def sync_documents(documents, options = {}, &block)
      Googletastic::Document.sync(documents, options, &block)
    end
    
    def sync_forms(forms, options = {}, &block)
      Googletastic::Form.sync(forms, options, &block)
    end
    
    def push(username, password, options = {})
      Googletastic.client_for(:app_engine).push(username, password, options)
    end    
    
    # POSTs to your registered application
    def post(options = {})
      url = URI.parse(options[:url])
      # POST update to registered application
      http = Net::HTTP.new(url.host, url.port)
      header = options[:header] || {}
      header.merge!('Content-Type' =>'application/json')
      data = options[:data].to_json
      response = http.post(options[:path], data, header)
    end
    
    def cleanup(syncables, options)
      syncables.each do |syncable|
        syncable.synced_at = Time.now
        syncable.save!
        path = File.join(options[:folder], syncable.title)
        path += options[:ext] if options.has_key?(:ext)
        begin
          File.delete(path)
        rescue Exception => e
          
        end
      end
    end
    
  end
  
end

require_local "sync/*", __FILE__