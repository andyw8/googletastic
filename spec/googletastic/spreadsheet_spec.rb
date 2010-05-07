require File.expand_path("./spec/spec_helper")

describe Googletastic::Spreadsheet do
  
  it "should retrieve a list of spreadsheets" do
    Googletastic::Spreadsheet.all
  end
  
  it "should retrieve the records from a single spreadsheet" do
    Googletastic::Spreadsheet.first.should be_an_instance_of(Googletastic::Spreadsheet)
  end
  
  it "should retrieve a spreadsheets worksheet" do
    Googletastic::Spreadsheet.first.worksheet.should_not be_nil
  end
  
  it "should retrieve a table within a spreadsheet" do
    pending
  end
  
  it "should retrieve a list of rows for a worksheet" do
    rows = Googletastic::Spreadsheet.first.rows
#    rows.each do |row|
#      row.data[:firstname] = "Appleseed"
#      row.save
#    end
  end
  
end