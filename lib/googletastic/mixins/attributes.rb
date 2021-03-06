module Googletastic::Mixins::Attributes
  attr_accessor :attributes
  
  def attributes=(value)
    return if value.nil?
    attributes = value.dup
    attributes.stringify_keys!
    @attributes = attributes
    attributes.each do |k, v|
      respond_to?(:"#{k}=") ? send(:"#{k}=", v) : raise("unknown attribute: #{k}")
    end
  end
  
  def attribute_names
    @attributes.keys.sort
  end
  
  def has_attribute?(attr_name)
    @attributes.has_key?(attr_name.to_s)
  end
  
  def inspect
    hash = ""
    attributes.each { |k,v| hash << " @#{k.to_s}=#{v.inspect}" unless k.to_s == "raw" }
    "#<#{self.class.to_s}#{hash}/>"
  end
end