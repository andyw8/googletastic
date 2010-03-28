require File.expand_path("./spec/spec_helper")

describe Googletastic::Calendar do
  
  describe "finding" do
    it "should retrieve a list of calendars from google calendar" do
      Googletastic::Calendar.all
    end
  end
  
end