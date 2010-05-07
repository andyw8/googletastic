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
    rows = Googletastic::Spreadsheet.find("tDewl4JDeSOAMMOiG9i2u-Q&hl").rows
    rows.each do |row|
      puts row.data.inspect
#      row.save
    end
  end
  
  it "should retrieve the form for the spreadsheet" do
    form = Googletastic::Spreadsheet.first.form
    puts form.inspect
  end
  
  it "should retrieve the form AND the formkey for the spreadsheet form" do
    form = Googletastic::Spreadsheet.first.form
    form.form_key
  end

  it "should create a map of input entries to spreadsheet row data properties" do
    spreadsheet = Googletastic::Spreadsheet.first
    form = spreadsheet.form
    form.set_defaults(spreadsheet.rows.first.data)
  end
  
end