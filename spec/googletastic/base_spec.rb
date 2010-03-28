require File.expand_path("./spec/spec_helper")

describe Googletastic::Base do
  
  # URL
  describe "url parsing" do
    it "should convert a hash of params into url parameters" do
      pending
    end

    it "should only convert 'valid_params' into url parameters" do
      pending
    end

    it "should throw an error if no url is specified in the params" do
      pending
    end

    it "should format the url properly with params" do
      options = {:offset => 10, :with => "LANCE", :reader => "JOHN", :url => "http://docs.google.com/"}
      # base
      url = Googletastic::Base.build_url(options)
      url.should == "http://docs.google.com/?q=LANCE&start-index=10"
    end
  end
  
  # AUTHENTICATION
  describe "authentication" do
    it "should find the configuration file" do
      pending
    end

    it "should successfully authenticate" do
      pending
    end
    
  end
  
  # http://code.google.com/apis/gdata/articles/gdata_on_rails.html#AuthSub
  it "should login via 'AuthSub'" do
    client = GData::Client::DocList.new
    next_url = 'http://accd.org'
    secure = false  # set secure = true for signed AuthSub requests
    sess = true
    domain = nil#'accd.org'  # force users to login to a Google Apps hosted domain
    authsub_link = client.authsub_url(next_url, secure, sess, domain)
  end
  
end