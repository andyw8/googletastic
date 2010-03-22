require File.expand_path("./spec/spec_helper")

describe Googletastic::Album do
  
  it "should retrieve a list of albums from picasa" do
    Googletastic::Album.all
  end
  
end