require File.expand_path("./spec/spec_helper")

describe Googletastic::Document do
  
  before(:all) do
    @doc = Document.new
  end
  
  # FIND METHODS
  it "should find first document from google docs" do
    google_doc = Googletastic::Document.first
#    google_doc.acl.inspect
  end
  
  it "should find all documents from google docs" do
    pending
  end
  
  it "should find single document by id from google docs" do
    doc_id = "0AT1-fvkm5vJPZGN2NzR3bmJfNmN2ampwdmNo"
    doc = Googletastic::Document.find(doc_id)
    doc.should_not == nil
  end
  
  it "should find single document by id from google docs, with ACL via ':include => [:acl]'" do
    pending
  end
  
  it "should retrieve ACL for document when called" do
    doc = Googletastic::Document.first
    doc.acl.should_not == nil
  end
  
  # URL PARSING
  it "should format the url properly with params" do
    options = {:offset => 10, :with => "LANCE", :reader => "JOHN", :url => "http://docs.google.com/"}
    # document
    url = Googletastic::Document.build_url(options)
    url.should == "http://docs.google.com/?reader=JOHN&q=LANCE&start-index=10"
    
    options = {:include => [:acl], :url => Googletastic::Document::FEED}
    url = Googletastic::Document.build_url(options)
    url.should =~ /#{Googletastic::Document::FEED.gsub(/full$/, "expandAcl")}/
  end
  
  it "should list all spreadsheets" do
    sheets = Googletastic::Spreadsheet.all
    sheets.length.should > 0
    sheets.each do |sheet|
      puts sheet.to_xml
    end
  end
  
  it "should post a document's content to google docs" do
    
  end
  
  it "should retrieve only the specified fields from the xml" do
    puts Googletastic::Document.all(:fields => "title,id").to_xml
  end
  
  # DOWNLOADING
  it "should get document by 'kind'" do
    pending
  end
  
  it "should get a '.doc' file from google docs and return it as html" do
    #doc = Thing::Google::Document.view(nil, {:q => "SLOVENIA"}).first
    #doc = Thing::Google::Document.get(doc, "zip")
    #test_html = File.join(FIXTURES_DIR, "doc_as_html_html.zip")
    #File.write(test_html, doc.body)
    pending
  end
  
end