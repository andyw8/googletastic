require File.expand_path("./spec/spec_helper")

describe Googletastic::AccessRule do
  
  it "should retrieve the acl for a test id" do
    doc_id = "document:0AT1-fvkm5vJPZGN2NzR3bmJfNmN2ampwdmNo"
    acl = Googletastic::AccessRule.find(:all, :document_id => doc_id)
    puts acl.inspect
#    doc = Googletastic::Document.find(doc_id, :include => :acl)
#    puts doc.to_xml
  end
  
end