# not sure where to fit this in yet
module Googletastic::PrettyPrint
  class << self
    def xml(xml)
      return "" if xml.nil?
      raise "will throw segmentation error if not an Nokogiri::XML::Document" unless xml.is_a?(Nokogiri::XML::Document)
      pretty_printer = File.join(File.dirname(__FILE__), "pretty_print.xsl")
      xsl = Nokogiri::XSLT(IO.read(pretty_printer))
      xsl.transform(xml).children.to_xml.gsub(/\t/, "")
    end
    
    def pretty_html(html)
      return "" if html.nil?
      raise "will throw segmentation error if not an Nokogiri::HTML::Document" unless xml.is_a?(Nokogiri::HTML::Document)
      pretty_printer = File.join(File.dirname(__FILE__), "pretty_print.xsl")
      xsl = Nokogiri::XSLT(IO.read(pretty_printer))
      # they get erased
      top_level_attributes = []
      elements = html.is_a?(Nokogiri::XML::NodeSet) ? html : [html]
      puts "ELEMENTS: #{elements[0].class}"
      elements.each do |element|
        top_level_attributes.push(element.attributes)
      end
      top_level_attributes.reverse!
      puts "??"
      children = xsl.transform(html)
      #.children
      # reapply top-level attributes
      puts "TOP ATTRIBUTES: #{top_level_attributes.inspect}"
      children.each do |child|
        attributes = top_level_attributes.pop
        attributes.each do |k,v|
          child[k] = v
        end unless attributes.nil?
      end
      children.to_html.gsub(/\t/, "")
    end
  end
end
