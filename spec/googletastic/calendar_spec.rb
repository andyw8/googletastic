require File.expand_path("./spec/spec_helper")

describe Googletastic::Calendar do
  
  it "should retrieve a list of calendars from google calendar" do
    puts Googletastic::Calendar.all.inspect
  end
  
end