require File.expand_path("./spec/spec_helper")

describe Googletastic::Event do
  
  it "should retrieve a list of events from google calendar" do
    puts Googletastic::Event.all.inspect
  end
  
end