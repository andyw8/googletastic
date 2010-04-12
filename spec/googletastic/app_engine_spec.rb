require File.expand_path("./spec/spec_helper")

describe Googletastic::AppEngine do
  
  it "should get the cookie for app engine" do
    client = Googletastic.client_for(:app_engine)
    url = "http://ilove4d-cdn.appspot.com/files/testing.html"
    response = client.get(url)
    puts response.body
  end
  
end