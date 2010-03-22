class Googletastic::Attendee < Hash # simple value object
  
  include Googletastic::Mixins::Attributes
  
  attr_accessor :email, :role, :name
  
end