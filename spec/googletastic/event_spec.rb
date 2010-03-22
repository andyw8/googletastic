require File.expand_path("./spec/spec_helper")

describe Googletastic::Event do
  
  it "should retrieve a list of events from google calendar" do
    Googletastic::Event.all.should_not == nil
  end
  
  it "should post an event on google calendar" do
    @event = Googletastic::Event.new
    @event.title = "Event with DESCRIPTION"
    @event.start_time = Time.now.xmlschema
    @event.end_time = 2.days.from_now.xmlschema
    @event.description = "You know, i hope this works!"
#    @event.save
  end
  
  it "should update (put) an even on google calendar" do
    @event = Googletastic::Event.first
    @event.title = "I CHANGED MY TITLE"
    @event.description = "Now I have a description?"
    @event.where = "Santa Rosa"
    @event.save
  end
  
  it "should get a 'content not modified' response from google" do
    pending
  end
  
end