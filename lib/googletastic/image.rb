class Googletastic::Image < Googletastic::Base
  
  attr_accessor :url, :width, :height, :size, :thumbnails, :title, :summary, :content_type
  attr_accessor :album_id, :access, :commentable, :id, :created_at, :updated_at, :kind
  
  class << self
    
    # http://code.google.com/apis/picasaweb/docs/2.0/reference.html#Parameters
    def valid_queries
      {
        :access => "access",
        :geo_coordinates => "bbox",
        :geo_location => "l",
        :image_max_size => "imgmax",
        :thumb_size => "thumbsize",
        :kind => "kind",
        :tag => "tag",
      }.merge(super)
    end
    
    def valid_access?(value)
      %w(all private public visible).include?(value)
    end
    
    def valid_image_max_size?(value)
      [94, 110, 128, 200, 220, 288, 320, 400, 512, 576, 640, 720, 800, 912, 1024, 1152, 1280, 1440, 1600].include?(value)
    end
    
    def valid_kind?(value)
      %w(album photo comment tag user).include?(value)
    end
    
    def client_class
      "Photos"
    end
    
    def index_url
      "http://picasaweb.google.com/data/feed/api/user/#{Googletastic.credentials[:username]}"
    end
    
    def build_url(options)
      base = options.has_key?(:url) ? options[:url] : self.index_url
      options[:url] = base
      options[:kind] = "photo" unless options.has_key?(:kind)
      options[:access] ||= "all"
      #options[:image_max_size] = 720 unless options.has_key?(:image_max_size)
      super(options)
    end
    
    def unmarshall(xml)
      records = xml.xpath("//atom:entry", ns_tag("atom")).collect do |record|
        # thumbnails
        thumbnails = record.xpath("media:group/media:thumbnail").collect do |thumbnail|
          url     = thumbnail["url"]
          width   = thumbnail["width"].to_i
          height  = thumbnail["height"].to_i
          Googletastic::Thumbnail.new(
            :url => url,
            :width => width,
            :height => height
          )
        end

        id            = record.xpath("atom:id", ns_tag("atom")).first.text
        created_at    = record.xpath("atom:published", ns_tag("atom")).first.text
        updated_at    = record.xpath("atom:updated", ns_tag("atom")).first.text
        kind          = "photo"
        title         = record.xpath("atom:title", ns_tag("atom")).first.text
        summary       = record.xpath("atom:summary", ns_tag("atom")).first.text
                    
        album_id      = record.xpath("gphoto:albumid", ns_tag("gphoto")).first.text
        access        = record.xpath("gphoto:access", ns_tag("gphoto")).first.text
        width         = record.xpath("gphoto:width", ns_tag("gphoto")).first.text.to_i
        height        = record.xpath("gphoto:height", ns_tag("gphoto")).first.text.to_i
        size          = record.xpath("gphoto:size", ns_tag("gphoto")).first.text.to_i
        
        commentable   = record.xpath("gphoto:commentingEnabled", ns_tag("gphoto")).first.text == "true" ? true : false
                    
        content       = record.xpath("media:group/media:content").first
        url           = content["url"].to_s
        content_type  = content["type"].to_s

        Googletastic::Image.new(
          :id => id,
          :created_at => created_at,
          :kind => kind,
          :title => title,
          :summary => summary,
          :album_id => album_id,
          :access => access,
          :width => width,
          :height => height,
          :size => size,
          :commentable => commentable,
          :url => url,
          :content_type => content_type,
          :thumbnails => thumbnails
        )
      end
      records
    end
    
    # not implemented
    def marshall(record)
      Nokogiri::XML::Builder.new { |xml| 
        xml.entry('xmlns' => Googletastic::ATOM_NS, 'xmlns:docs' => ns("docs")) {
          if record.id
            xml.id {
              xml.text show_url(record.id)
            }
          end
          xml.title {
            xml.text record.title
          }
        }
      }.to_xml
    end
    
  end
  
end