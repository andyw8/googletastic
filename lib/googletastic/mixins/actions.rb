module Googletastic::Mixins::Actions
  include_class_and_instance_modules
  
  module ClassMethods
    
  end
  
  module InstanceMethods
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
          self.class.client.post_file(self.class.feed_url, self.attachment_path, mime_type, self.to_xml)
        else
          self.class.client.post(self.class.feed_url, self.to_xml)
        end
      end

      def update(attribute_names = @attributes.keys)
        if has_attachment?
          self.class.client.put_file(self.class.feed_url, self.attachment_path, mime_type, self.to_xml)
        else
          self.class.client.put(self.edit_url || self.class.feed_url, self.to_xml)
        end
      end
  end
  
end