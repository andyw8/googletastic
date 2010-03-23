module Googletastic::Mixins::Parsing
  
  def self.included(base)
    base.extend(ClassMethods)
    base.class_eval do
      include InstanceMethods
      
      # if you want to hook into these processes easily,
      # without having to override/copy-paste/alias-method
      # they're placed at convenient locations
      # define them as a block
      # base.define_callbacks :before_unmarshall, :during_unmarshall, :after_unmarshall
    end
  end
  
  module ClassMethods
    
    # cached nokogiri xml, false by default
    attr_accessor :cache_parsed

    def cache_parsed?
      @cache_parsed == true
    end
    
    # cache xml as string?
    attr_accessor :cache_result
    
    def cache_result?
      @cache_result == true
    end
    
    # implement in subclasses
    def unmarshall(xml_records)
      raise "Implemnent in subclasses"
    end
    
    # implement in subclasses
    def marshall(records)
      raise "Implemnent in subclasses"
    end
  end
  
  module InstanceMethods
    # cached nokogiri xml, false by default
    attr_accessor :cache_parsed
    
    def cache_parsed?
      @cache_parsed != false || self.class.cache_result?
    end
    
    # cache xml as string?
    attr_accessor :cache_result
    
    def cache_result?
      @cache_result != false || self.class.cache_result?
    end
    
    def from_xml(xml)
      self.class.unmarshall(xml)
    end

    def after_parse(parsed)

    end
    
  end
  
end