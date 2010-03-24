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
  
end