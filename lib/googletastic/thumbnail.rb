class Googletastic::Thumbnail < Hash # simple value object
  
  include Googletastic::Mixins::Attributes
  
  attr_accessor :url, :width, :height
  
end