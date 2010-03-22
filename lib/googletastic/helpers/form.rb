module Googletastic::Helpers::Form
  
  def self.included(base)
    base.extend ClassMethods
    base.class_eval do
      include InstanceMethods
    end
  end
  
  module InstanceMethods
    attr_accessor :g_form
    
    def hello
    end
    
    def google_doc
      @google_doc ||= Googletastic::DocList.find(self.remote_id)
      @google_doc
    end
  end
  
  module ClassMethods
    
    def g_form
      
    end
    
  end
end