require File.expand_path("./spec/spec_helper")

describe Googletastic::Form do
  
  before(:all) do
    @form = Form.new
  end
  
  describe "find" do
    it "should list all spreadsheets as forms" do
      
    end
  end
  
  describe "dynamic helper methods" do
    it "should add dynamic methods to form model based on googletastic :form options" do
      @form.respond_to?(:google_form).should == true
    end

    it "should respond_to?(:find_with_google_form) dynamic class methods" do
      Form.respond_to?(:find_with_google_form).should == true
      pending
    end
  end
  
  describe "unmarshalling" do
    it "should strip the html page down to a form (unmarshall)" do
      @html = Nokogiri::HTML(IO.read(File.join(FIXTURES_DIR, "data/form.html")))
      form = Googletastic::Form.unmarshall(@html)
      form.redirect = "/forms/my-custom-id"
    end
  end
  
  describe "redirecting" do
    it "should add generic redirect" do
      Googletastic::Form.redirect_to = "/my-generic-redirect"
      @html = Nokogiri::HTML(IO.read(File.join(FIXTURES_DIR, "data/form.html")))
      form = Googletastic::Form.unmarshall(@html)
      Nokogiri::HTML(form.body).xpath("//form").first["action"].should == "/my-generic-redirect"
    end
  end
  
end