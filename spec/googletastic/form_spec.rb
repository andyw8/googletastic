require File.expand_path("./spec/spec_helper")

describe Googletastic::Form do
  
  before(:all) do
    @form = Form.new
  end
  
  it "should strip the html page down to a form (unmarshall)" do
    html = Nokogiri::HTML(IO.read(File.join(FIXTURES_DIR, "data/form.html")))
    form = Googletastic::Form.unmarshall(html)
    form.redirect = "/forms/my-custom-id"
    puts form.body
  end
end