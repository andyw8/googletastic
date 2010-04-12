module Googletastic::Sync::Document
  
  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    
    def sync(documents, options, &block)
      updated = process(documents, options)
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
    
    def process(documents, options = {})
      options[:key] ||= "documents"
      # defaults to a reasonable limit (3MB) for heroku
      options[:max_size] ||= 3000000
      # per max_size chunk
      documents_processed = []
      # total
      updated_documents = []
      counted_size = 0
      documents.each_with_index do |document, index|
        next if document.remote.kind != "document"
        if document.synced_at and document.synced_at >= document.remote.updated_at
          puts "Skipping Document... #{document.title}"
          if documents_processed.length > 0 and index == documents.length - 1
            Googletastic::Sync.push(options[:username], options[:password], options)
            cleanup(documents_processed, options)
          end
          next
        end
        remote  = document.remote
        content = nil
        title   = remote.title
        ext     = remote.ext
        puts "Processing Document... #{document.title}"
        begin
          if ext == ".textile"
            # google is putting strange characters at beginning of downloaded files
            content = remote.download("txt").body.gsub(/\357\273\277/, "")
            content = RedCloth.new(content).to_html
          elsif ext == ".markdown"
            content = remote.download("txt").body.gsub(/\357\273\277/, "")
            content = BlueCloth.new(content).to_html
          elsif ext.nil? || ext.empty?
            # just use the html we have already
            content = remote.content
          else
            content = remote.download("txt").body.gsub(/\357\273\277/, "")
          end
          
          document.content = content
          title = remote.id
          
          tempfile = Tempfile.new("googltastic-tempfiles-#{title}-#{Time.now}-#{rand(10000)}")
          tempfile.write(content)

          path = File.join(options[:folder], options[:key])
          Dir.mkdir(path) unless File.exists?(path)
          path = File.join(path, title)
          
          # if we have passed the 5MB (or our 3MB) limit,
          # then push the files to GAE
          if tempfile.size + counted_size >= options[:max_size] || index == documents.length - 1
            Googletastic::Sync.push(options[:username], options[:password], options)
            cleanup(documents_processed, options)
            counted_size = 0
            documents_processed = []
          end
          File.open(path, 'w') {|f| f.write(content) }
          documents_processed << document
          counted_size += tempfile.size
          tempfile.close
          
          updated_documents << document

        rescue Exception => e
          puts "Error... #{e.inspect}"
        end
      end
    
      updated_documents
    end
    
    def cleanup(syncables, options)
      syncables.each do |syncable|
        syncable.synced_at = Time.now
        syncable.save!
        path = File.join(options[:folder], options[:key], syncable.remote.id)
        path += options[:ext] if options.has_key?(:ext)
        begin
          File.delete(path)
        rescue Exception => e
          
        end
      end
    end
  end
end

Googletastic::Document.class_eval do
  include Googletastic::Sync::Document
end