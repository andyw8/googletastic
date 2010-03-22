class Googletastic::Base < Hash
  
  class << self # Class methods
    
    # override if you name classes differently
    def client_class
      self.to_s.split("::").last
    end
    
    def valid_queries
      {
        :limit => "max-result",
        :offset => "start-index",
        :start => "start-index",
        :end => "end-index",
        :categories => "category",
        :with => "q"
      }
    end
  end
  
  attr_accessor :id, :acl
  attr_accessor :attachment_path # for docs, images...
  
  def save
    create_or_update
  end
  
  def destroy
    
  end
  
  def clone
    
  end

  def reload(options = nil)
  end
  
  def new_record?
    true
  end
  
  def to_xml
    self.class.marshall(self)
  end
  
  def view_url
  end
  
  def download_url(format = "pdf")
  end
  
  def edit_url
  end
  
  def has_attachment?
    !self.attachment_path.nil?
  end
  
  def mime_type
    return "" if has_attachment?
    return "" #TODO
  end
  
  private
    def create_or_update
      result = new_record? ? create : update
      result != false
    end
    
    def create
      if has_attachment?
        client.post_file(self.class.feed_url, self.attachment_path, mime_type, self.to_xml)
      else
        client.post(self.class.feed_url, self.to_xml)
      end
    end
    
    def update(attribute_names = @attributes.keys)
    end
  
end