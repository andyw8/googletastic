# from http://github.com/mocra/custom_google_forms
class Googletastic::Form < Googletastic::Base
  
  attr_accessor :title, :body, :raw, :redirect_to, :form_key
  
  def redirect_to=(value)
    self.class.add_redirect(raw, value)
  end
  
  def get(redirect = nil)
    old_redirect =  self.class.redirect_to
    self.class.redirect_to = redirect if redirect
    new_record = self.class.find_by_api(:entryID => self.form_key)
    self.class.redirect_to = old_redirect
    if new_record and new_record.is_a?(Googletastic::Form)
      self.body = new_record.body
      self.title = new_record.title
    end
    self.body
  end
  
  def body
    @body ||= get
    @body
  end
  
  class << self
    
    attr_accessor :redirect_to, :form_only
    
    def form_url(id)
      "http://spreadsheets.google.com/viewform?formkey=#{id}"
    end
    
    def submit_to(id = "")
      "http://spreadsheets.google.com/formResponse?formkey=#{id}"
    end
    
    def all(*args)
      Googletastic::Spreadsheet.all
    end
    
    # there is no form api :/
    def find_by_api(options)
      record = fetch_form_page(options[:entryID])
    end
    
    def unmarshall(html)
      action = html.xpath("//form").first["action"].to_s
      id = action.gsub(self.submit_to, "")
      title = html.xpath("//h1[@class='ss-form-title']").first.text
      body = content(html, id)
      form = Googletastic::Form.new(
        :id => id,
        :title => title,
        :body => body.to_html
      )
    end
    
    def marshall(record)
      return record.inspect
    end
    
    def fetch_form_page(id)
      uri = URI.parse(form_url(id))
      req = Net::HTTP::Get.new("#{uri.path}?#{uri.query}")
      response = Net::HTTP.new(uri.host).start {|h| h.request(req)}
      return response.is_a?(Net::HTTPSuccess) ? unmarshall(Nokogiri::HTML(response.body)) : response
    end
    
    def content(doc, submit_key)
      if self.redirect_to
        add_redirect(doc, self.redirect_to, submit_key)
      end
      if self.form_only
        doc.xpath("//form").first.unlink
      else
        doc.xpath("//div[@class='ss-footer']").first.unlink
        doc.xpath("//div[@class='ss-form-container']").first.unlink
      end
    end
    
    def add_redirect(doc, redirect, submit_key)
      form = doc.xpath("//form").first
      
      form["enctype"] = "multipart/form-data"      
      
      # don't have time to build this correctly
      if redirect.is_a?(String)
        form["action"] = redirect
      else
        form["action"] = redirect[:url]
        if redirect.has_key?(:params)
          redirect[:params].each do |k,v|
            hidden_node = doc.create_element('input')
            hidden_node["name"] = k.to_s
            hidden_node["type"] = "hidden"
            hidden_node["value"] = v.to_s
            form.children.first.add_previous_sibling(hidden_node)
          end
        end
      end
      
      hidden_node = doc.create_element('input')
      hidden_node["name"] = "submit_key"
      hidden_node["type"] = "hidden"
      hidden_node["value"] = submit_key
      form.children.first.add_previous_sibling(hidden_node)
      
      put_node = doc.create_element('input')
      put_node["name"] = "_method"
      put_node["type"] = "hidden"
      put_node["value"] = "put"
      form.children.first.add_previous_sibling(put_node)

      form
    end
    
  end
  
  def redirect=(value)
    self.body = self.class.add_redirect(Nokogiri::HTML(body), value).to_html
    value
  end
  
  def submit(form_key, params)
    google_form_action = self.class.submit_to(form_key)
    puts "SUBMIT TO GOOGLE: #{google_form_action.to_s}"
    uri = URI.parse(google_form_action)
    req = Net::HTTP::Post.new("#{uri.path}?#{uri.query}")
    req.form_data = params
    response = Net::HTTP.new(uri.host).start {|h| h.request(req)}
    response
  end
  
  def view_url
    "http://spreadsheets.google.com/viewform?formkey=#{id}"
  end
end
