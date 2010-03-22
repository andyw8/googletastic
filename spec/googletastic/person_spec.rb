require File.expand_path("./spec/spec_helper")

describe Googletastic::Person do
  
  it "should retrieve a list of people from google contacts" do
    Googletastic::Person.all
  end
  
end