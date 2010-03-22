require File.expand_path("./spec/spec_helper")

describe Googletastic::Image do
  
  it "should retrieve a list of photos from picasa" do
    puts Googletastic::Image.all.inspect
  end
  
end