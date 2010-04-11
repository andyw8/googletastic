require File.expand_path("./spec/spec_helper")
# spec ./spec/googletastic/document_spec.rb

describe Googletastic::Document do
  
  before(:all) do
    @doc = Document.new
    @id = "0AT1-fvkm5vJPZGN2NzR3bmJfMGZiMnh3N2R0"
  end
  
  # FIND METHODS
  describe "find methods" do
    it "should find first document from google docs" do
      doc = Googletastic::Document.first
      doc.should_not == nil
      doc.title.should_not be_empty
    end
    
    it "should find all documents from google docs, and they should be an array" do
      docs = Googletastic::Document.all
      docs.should_not == nil
      docs.class.to_s.should == "Array"
    end
    
    it "should find single document by id from google docs" do
      doc = Googletastic::Document.find(@id)
      doc.should_not == nil
      doc.id.should == @id
    end
    
    it "should find single document by id from google docs, with ACL via ':include => [:acl]'" do
      pending
    end
  
    it "should retrieve ACL for document when called" do
      doc = Googletastic::Document.first
      doc.acl.should_not == nil
    end

    it "should retrieve only the specified fields from the xml" do
#      result = Googletastic::Document.all(:fields => "title,id", :raw => true)
#      puts Nokogiri::XML(result.body).to_xml
      pending
    end
    
    it "should get document by 'kind' of 'spreadsheet'" do
#      Googletastic::Document.first(:kind => "spreadsheet")
      pending
    end
    
    describe "errors" do
      it "should throw an error if you don't pass 'find' any parameters" do
#        Googletastic::Document.find.should raise_error
      end
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
      xml.xpath("//atom:id", {"atom" => NS['atom']}).first.text.should == "#{@doc.index_url.gsub('http', 'https').gsub('documents', 'default')}/#{@doc.resource_id}"
      xml.xpath("//atom:title", {"atom" => NS['atom']}).first.text.should == @doc.title
    end
  end
  
  describe "viewing" do
    it "should pull the raw html content of the document down" do
      doc = Googletastic::Document.find(@id)
      view = doc.view
      liquid = Liquid::Template.parse(view.to_xml.to_xml)
      result = liquid.render("company_name" => "My Company")
    end
    
    it "should return a 'Content Not Modified' response" do
      client = Googletastic::Document.client
      since = '2010-03-28T22:51:51.488Z'
      good = '2009-11-04T10:57:00-08:00'
      # AkQFRnw7fCp7ImA9WxBaGEw.
      client.headers["If-Modified-Since"] = since
      url = Googletastic::Document.index_url + "?updated-max=#{good}"
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
      doc = Googletastic::Document.find(@id)
      result = doc.download("txt")
      liquid = Liquid::Template.parse(result.body)
      result = liquid.render("company_name" => "My Company")
      File.write(File.join(FIXTURES_DIR, "results/test.txt"), result)
      result.should_not == nil
    end
    
    it "should get a '.doc' file from google docs and return it as html" do
      pending
    end
    
    it "should download all documents as a zip file" do
      
    end
  end
  
  describe "active record wrapper" do
    it "should have the dynamic method 'find_with_google_doc'" do
      Document.respond_to?(:find_with_google_doc).should == true
    end
    
    it "should find and save all new documents" do
      # Document.find_with_google_doc.should_not == nil
    end
    
    it "should be able to compare previous updated time with current updated time" do
      doc = Googletastic::Document.first
      puts doc.inspect
    end
  end
end