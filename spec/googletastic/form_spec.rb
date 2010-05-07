require File.expand_path("./spec/spec_helper")

describe Googletastic::Form do
  
  before(:all) do
    @form = Form.new
  end
  
  describe "find" do
    it "should list all spreadsheets as forms" do
      Googletastic::Form.all.each do |form|
        form.should be_an_instance_of(Googletastic::Form)
      end
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
  
  describe "mechanize" do
    it "it should get the formkey via mechanize" do
      form = Googletastic::Form.first
      formkey = form.get_form_key
      puts "FORMKEY: #{formkey}"
      formkey.should_not be_nil
    end
    
    it "should remove unnecessary html from form" do
      form = Googletastic::Form.first
      form.form_key = form.get_form_key
      body = form.body
      puts "BODY!: #{body.to_s}"
      body.should_not == nil
    end
  end
  
  
end