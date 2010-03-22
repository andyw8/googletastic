module Googletastic::Helpers
  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods

    def googletastic(model, options = {})
      include ("Googletastic::Helpers::#{model.to_s.camelize}").constantize
    end
    
  end
end

require_local "helpers/*", __FILE__