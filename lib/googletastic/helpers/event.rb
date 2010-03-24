module Googletastic::Helpers::EventModelHelper
  
  def self.included(base, &block)
    base.extend ClassMethods
    base.class_eval do
      include InstanceMethods
    end
  end
  
  module InstanceMethods
    attr_accessor :google_doc
    
    def hello
#      puts _googletastic_options.inspect + " OPTIONS!"
    end
    
    def google_doc
      @google_doc ||= Googletastic::DocList.find(self.remote_id)
      @google_doc
    end
  end
  
  module ClassMethods
    
  end
end