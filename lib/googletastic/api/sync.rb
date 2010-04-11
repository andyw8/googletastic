module Googletastic::Api::Sync

  class << self
  
    def push(username, password, options = {})
      Googletastic.client_for(:app_engine).push(username, password, options)
    end
    
    def process_documents(documents, options = {})
      # defaults to a reasonable limit (3MB) for heroku
      options[:max_size] ||= 3000000
      # per max_size chunk
      documents_processed = []
      # total
      updated_documents = []
      documents.each_with_index do |document, index|
        next if document.remote.kind != "document"
        next if document.synced_at and document.synced_at <= document.remote.updated_at
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
            title = title.gsub(/#{Regexp.escape(ext)}$/, ".html")
          elsif ext == ".markdown"
            content = remote.download("txt").body.gsub(/\357\273\277/, "")
            content = BlueCloth.new(content).to_html
            title = title.gsub(/#{Regexp.escape(ext)}$/, ".html")
          elsif ext.nil? || ext.empty?
            # just use the html we have already
            content = remote.content
            title = "#{title}.html"
          else
            content = remote.download("txt").body.gsub(/\357\273\277/, "")
          end
        
          document.content = content
          document.title = title
        
          tempfile = Tempfile.new("googltastic-tempfiles-#{title}-#{Time.now}-#{rand(10000)}")
          tempfile.write(content)

          path = File.join(options[:folder], title)

          # if we have passed the 5MB (or our 3MB) limit,
          # then push the files to GAE
          if tempfile.size + counted_size >= options[:max_size] || index == documents.length - 1
            push(options[:username], options[:password], options)
            cleanup(documents_processed)
            counted_size = 0
            documents_processed = []
          end
        
          File.open(path, 'w') {|f| f.write(content) }
          documents_processed << document
          counted_size += tempfile.size
          tempfile.close

          updated_documents << document

        rescue Exception => e
          puts "ERROR: #{e.inspect}"
        end
      end
    
      updated_documents
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
  
    def cleanup(documents)
      documents.each do |document|
        document.synced_at = Time.now
        document.save!
        path = File.join(options[:folder], document.title)
        begin
          File.delete(path)
        rescue Exception => e
        
        end
      end
    end
    
  end
end