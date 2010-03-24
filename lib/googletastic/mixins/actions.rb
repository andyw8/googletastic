module Googletastic::Mixins::Actions
  include_class_and_instance_modules
  
  module ClassMethods
    
    # see the data live on google docs
    def show_url(id)
      raise "Implement in Sublass"
    end
    
    # edit the data on google docs
    def edit_url(id)
      raise "Implement in Subclass"
    end
    
    # update the data via xml
    def update_url(id)
      raise "Implement in Subclass"
    end
    
    # xml feed
    def index_url(ids = nil)
      raise "Implement in Subclass"
    end
    
    # xml entry feed
    def get_url(id)
      raise "Implement 'get' in subclass"
    end
    
    def upload_url(id = nil)
      raise "Implement in Subclass"
    end
    
    def download_url(id)
      raise "Implement in Subclass"
    end
  end
  
  module InstanceMethods
    def show_url
      self.class.show_url(self.id)
    end

    def edit_url
      self.class.edit_url(self.id)
    end

    def index_url(ids = nil)
      self.class.index_url(ids)
    end
    
    def get_url
      self.class.get_url(self.id)
    end

    def update_url
      self.class.update_url(self.id)
    end

    def download_url
      self.class.download_url(self.id)
    end

    def upload_url
      puts "UPLOADURL"
      self.class.upload_url(self.id)
      puts "POST"
    end
      
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
      self.id.nil?
    end
    
    private
      def create_or_update
        result = new_record? ? create : update
        result != false
      end

      def create
        if has_attachment?
          self.class.client.post_file(self.class.index_url, self.attachment_path, mime_type, self.to_xml)
        else
          self.class.client.post(self.class.index_url, self.to_xml)
        end
      end

      def update(attribute_names = @attributes.keys)
        if has_attachment?
          self.class.client.put_file(self.class.index_url, self.attachment_path, mime_type, self.to_xml)
        else
          self.class.client.put(self.edit_url || self.class.index_url, self.to_xml)
        end
      end
  end
  
end