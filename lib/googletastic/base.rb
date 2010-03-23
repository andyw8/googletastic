class Googletastic::Base < Hash
  
  include Googletastic::Mixins::Namespaces
  include Googletastic::Mixins::Attributes
  include Googletastic::Mixins::Requesting
  include Googletastic::Mixins::Parsing
  include Googletastic::Mixins::Finders
  include Googletastic::Mixins::Actions
  
  attr_accessor :id
  attr_accessor :acl
  attr_accessor :attachment_path # for docs, images...
  # classes/records it is synced with
  attr_accessor :synced_with
  
  def synced_with
    @synced_with ||= []
    @synced_with
  end
  
  def initialize(attributes = {})
    return if attributes.nil?
    if (attributes.has_key?(:parsed))
      # haven't figured out how to do callbacks correctly
      after_parse(attributes[:parsed])
      attributes.delete(:parsed)
    end
    self.attributes = attributes 
  end
  
  class << self # Class methods
    
    # override if you name classes differently
    def client_class
      self.to_s.split("::").last
    end
    
  end
  
end