module Googletastic::Mixins::Namespaces
  
  NAMESPACES = {
    "gphoto" => "http://schemas.google.com/photos/2007",
    "media" => "http://search.yahoo.com/mrss",
    "openSearch" => "http://a9.com/-/spec/opensearchrss/1.0/",
    "docs" => "http://schemas.google.com/docs/2007",
    "atom" => "http://www.w3.org/2005/Atom",
    "gd" => "http://schemas.google.com/g/2005",
    "gAcl" => "http://schemas.google.com/acl/2007",
    "exif" => "http://schemas.google.com/photos/exif/2007",
    "app" => "http://www.w3.org/2007/app",
    "gCal" => "http://schemas.google.com/gCal/2005",
    "gContact" => "http://schemas.google.com/contact/2008",
    "batch" => "http://schemas.google.com/gdata/batch",
    "gs" => "http://schemas.google.com/spreadsheets/2006",
    "gsx" => "http://schemas.google.com/spreadsheets/2006/extended"
  } unless defined?(NAMESPACES)
    
  def self.included(base)
    base.extend ClassMethods
  end
  
  module ClassMethods
    def ns(name)
      NAMESPACES[name]
    end
  
    def ns_tag(name)
      {name => ns(name)}
    end
    
    def ns_xml(*names)
      first = names[0]
      names.inject({}) do |hash, name|
        xmlns = "xmlns"
        xmlns << ":#{name}" unless name == first
        hash[xmlns] = ns(name)
        hash
      end
    end
  end
  
end