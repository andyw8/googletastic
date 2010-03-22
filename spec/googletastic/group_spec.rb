require File.expand_path("./spec/spec_helper")

describe Googletastic::Group do
  
  it "should retrieve a list of groups from google contacts" do
    puts Googletastic::Group.all.inspect
  end
  
end