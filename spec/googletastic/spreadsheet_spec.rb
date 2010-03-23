require File.expand_path("./spec/spec_helper")

describe Googletastic::Spreadsheet do
  
  it "should retrieve a list of spreadsheets" do
    puts Googletastic::Spreadsheet.all.inspect
  end
  
end