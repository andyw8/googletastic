class Googletastic::Base < Hash
  
  include Googletastic::Mixins::Namespaces
  include Googletastic::Mixins::Attributes
  include Googletastic::Mixins::Requesting
  include Googletastic::Mixins::Parsing
  include Googletastic::Mixins::Finders
  include Googletastic::Mixins::Actions
  
  # ID's are specifically the hash key for each entry.
  # They don't include the url for finding the document,
  # which can be inferred from the "action" you're taking on it,
  # and the general api.
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
    self.attributes = attributes unless attributes.nil?
  end
  
  class << self # Class methods
    
    # This is referring to the gdata gem's implementation,
    # which more closely maps to the google api
    # override if you name classes differently.
    def client_class
      self.to_s.split("::").last
    end
    
  end
  
  def to_xml
    self.class.marshall(self)
  end
  
end