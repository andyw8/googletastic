require File.expand_path("./spec/spec_helper")
# spec ./spec/googletastic/document_spec.rb

describe Googletastic::Document do
  
  before(:all) do
    @doc = Document.new
  end
  
  # FIND METHODS
  describe "find methods" do
    it "should find first document from google docs" do
      doc = Googletastic::Document.first
      doc.should_not == nil
    end
  
    it "should find all documents from google docs, and they should be an array" do
      docs = Googletastic::Document.all
      docs.should_not == nil
      docs.class.to_s.should == "Array"
    end
  
    it "should find single document by id from google docs" do
      doc_id = "0AT1-fvkm5vJPZGN2NzR3bmJfNmN2ampwdmNo"
      doc = Googletastic::Document.find(doc_id)
      doc.should_not == nil
      doc.id.should == doc_id
    end
  
    it "should find single document by id from google docs, with ACL via ':include => [:acl]'" do
      pending
    end
  
    it "should retrieve ACL for document when called" do
      doc = Googletastic::Document.first
      doc.acl.should_not == nil
    end

    it "should retrieve only the specified fields from the xml" do
      pending
  #    puts Googletastic::Document.all(:fields => "title,id").to_xml
    end
    
    it "should get document by 'kind' of 'spreadsheet'" do
      pending
    end
  end
  
  describe "document properties" do
    before(:all) do
      @doc = Googletastic::Document.first
    end
    
    it "should have a valid 'kind'" do
      @doc.kind.should_not == nil
      Googletastic::Document.valid_category?(@doc.kind).should == true
    end
    
    it "should have an array of categories" do
      @doc.categories.should be_an_instance_of(Array)
    end
  end
  
  # URL PARSING
  describe "url parsing" do
    it "should format the url properly with params" do
      options = {:offset => 10, :with => "LANCE", :reader => "JOHN", :url => "http://docs.google.com/"}
      # document
      url = Googletastic::Document.build_url(options)
      url.should == "http://docs.google.com/?reader=JOHN&q=LANCE&start-index=10"
    
      options = {:include => [:acl], :url => Googletastic::Document::FEED}
      url = Googletastic::Document.build_url(options)
      url.should =~ /#{Googletastic::Document::FEED.gsub(/full$/, "expandAcl")}/
    end
  end
  
  describe "marshalling" do
    before(:all) do
      @doc = Googletastic::Document.first
      @xml = @doc.to_xml
    end
    
    it "should marshall the document into an entry feed with at least a 'title' and 'id'" do
      xml = Nokogiri::XML(@xml)
      xml.xpath("//atom:id", {"atom" => NS['atom']}).first.text.should == "#{@doc.get_url}/#{@doc.resource_id}"
      xml.xpath("//atom:title", {"atom" => NS['atom']}).first.text.should == @doc.title
    end
  end
  
  describe "viewing" do
    it "should pull the raw html content of the document down" do
      
    end
  end
  
  describe "uploading" do
    it "should post a document's content to google docs" do
#      response = Googletastic::Document.upload(File.join(FIXTURES_DIR, "data/basic.txt"))
#      response.should_not == nil # better assertion :p, but it works
    end
    
    it "should upload the document's content and add a custom title" do
      
    end
  end
  
  # DOWNLOADING
  describe "downloading" do
    it "should download a document as plain text" do
#      doc = Googletastic::Document.download("0AT1-fvkm5vJPZGN2NzR3bmJfMTlkNHRjZHpnNg", :format => "pdf")
#      doc.should_not == nil
      pending
    end

    it "should get a '.doc' file from google docs and return it as html" do
      pending
    end
    
    it "should download all documents as a zip file" do
      
    end
  end
  
  describe "active record wrapper" do
    
  end
end