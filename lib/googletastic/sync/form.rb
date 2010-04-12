module Googletastic::Sync::Form
  
  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    
    def sync(forms, options = {}, &block)
      updated = process(forms, options)
      key = options[:key].to_s
      data = {key => []}
      updated.each do |form|
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
    
    def process(forms, options = {})
      options[:key] ||= "forms"
      # defaults to a reasonable limit (3MB) for heroku
      options[:max_size] ||= 3000000
      # per max_size chunk
      forms_processed = []
      # total
      updated_forms = []
      counted_size = 0
      forms.each_with_index do |form, index|
        if form.formkey.nil?
          puts "Missing formkey... #{form.title}"
          if forms_processed.length > 0 and index == forms.length - 1
            Googletastic::Sync.push(options[:username], options[:password], options)
            cleanup(forms_processed, options.merge(:ext => ".html"))
          end
          next
        end
        remote  = form.remote
        content = nil
        puts "Processing Form... #{form.title}"
        begin
          form.remote.form_key = form.formkey
          title = form.formkey + ".html"
          content = form.remote.body
          
          tempfile = Tempfile.new("googltastic-form-tempfiles-#{title}-#{Time.now}-#{rand(10000)}")
          tempfile.write(content)
          
          path = File.join(options[:folder], options[:key])
          Dir.mkdir(path) unless File.exists?(path)
          path = File.join(path, title)
          
          # if we have passed the 5MB (or our 3MB) limit,
          # then push the files to GAE
          if tempfile.size + counted_size >= options[:max_size] || index == forms.length - 1
            Googletastic::Sync.push(options[:username], options[:password], options)
            cleanup(forms_processed, options.merge(:ext => ".html"))
            counted_size = 0
            forms_processed = []
          end
          File.open(path, 'w') {|f| f.write(content) }
          forms_processed << form
          counted_size += tempfile.size
          tempfile.close

          updated_forms << form
          
        rescue Exception => e
          puts "Error... #{e.inspect}"
        end
      end
      
      updated_forms
    end
    
    def cleanup(syncables, options)
      syncables.each do |syncable|
        syncable.synced_at = Time.now
        syncable.save!
        path = File.join(options[:folder], options[:key], syncable.formkey)
        path += options[:ext] if options.has_key?(:ext)
        begin
          File.delete(path)
        rescue Exception => e
          
        end
      end
    end
    
  end
end

Googletastic::Form.class_eval do
  include Googletastic::Sync::Form
end