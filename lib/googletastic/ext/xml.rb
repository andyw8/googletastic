# not sure where to fit this in yet
module Googletastic::PrettyPrint
  class << self
    def xml(xml)
      pretty_printer = File.join(File.dirname(__FILE__), "pretty_print.xsl")
      xsl = Nokogiri::XSLT(IO.read(pretty_printer))
      xsl.transform(xml).children.to_xml.gsub(/\t/, "")
    end
  end
end
