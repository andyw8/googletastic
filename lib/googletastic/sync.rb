module Googletastic::Sync
  
  class << self
    
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
    
    def sync_documents(documents, options = {}, &block)
      updated = Googletastic::Sync::Document.process(documents, options)
      options[:key] ||= "documents"
      key = options[:key].to_s
      data = {key => []}
      documents.each do |document|
        data[key] << {
          :id => document.remote.id
        }
        yield(data, key, document) if block_given?
      end
      response = Googletastic::Sync.post(
        :url => options[:url],
        :path => options[:path],
        :format => :json,
        :data => data
      )
    end
    
    def sync_forms(forms, options = {}, &block)
      updated = Googletastic::Sync::Form.process(forms, options)
      options[:key] ||= "forms"
      key = options[:key].to_s
      data = {key => []}
      forms.each do |form|
        data[key] << {
          :id => form.remote.id,
          :formkey => form.formkey
        }
        yield(data, key, form) if block_given?
      end
      response = Googletastic::Sync.post(
        :url => options[:url],
        :path => options[:path],
        :format => :json,
        :data => data
      )
    end
      
    def cleanup(documents, options)
      documents.each do |document|
        document.synced_at = Time.now
        document.save!
        path = File.join(options[:folder], "documents", document.title)
        begin
          File.delete(path)
        rescue Exception => e
          
        end
      end
    end
    
  end
  
end

require_local "sync/*", __FILE__