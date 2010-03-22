=begin
module Thing
  module Google
    class YouTube < CouchRest::ExtendedDocument
      
      MEDIA_NS = "http://search.yahoo.com/mrss" unless defined?(MEDIA_NS)
      YT_NS = "http://gdata.youtube.com/schemas/2007" unless defined?(YT_NS)
      
      API = "http://gdata.youtube.com" unless defined?(API)
      GET_UPLOAD_TOKEN = "action/GetUploadToken"
      UPLOAD = "http://uploads.gdata.youtube.com/feeds/api/users"
      MULTIPART = "multipart/related"
      
      def self.unmarshall(object)
        
      end
      
      def self.marshall(xml)
        
      end
      
    end
  end
end
=end