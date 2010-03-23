# from http://github.com/mocra/custom_google_forms
class Googletastic::Form < Googletastic::Base
  
  attr_accessor :title, :body, :raw, :redirect_to
  
  def redirect_to=(value)
    self.class.add_redirect(raw, value)
  end
  
  def get
    self.class.fetch_form_page(self.id)
  end
  
  class << self
    
    attr_accessor :redirect_to
    
    def form_url(id)
      "http://spreadsheets.google.com/viewform?formkey=#{id}"
    end
    
    def all(*args)
      Googletastic::Spreadsheet.all
    end
    
    # there is no form api :/
    def find_by_api(options)
      record = fetch_form_page(options[:entryID])
    end
    
    def unmarshall(html)
      id = html.xpath("//form").first["action"].to_s.gsub("http://spreadsheets.google.com/formResponse?formkey=", "")
      title = html.xpath("//h1[@class='ss-form-title']").first.text
      body = content(html)
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
    
    def content(doc, &block)
      if self.redirect_to
        add_redirect(doc, self.redirect_to)
      end
      doc.xpath("//form").first.unlink
    end
    
    def add_redirect(doc, value)
      form = doc.xpath("//form").first

      original_action = form["action"]
      # don't have time to build this correctly
      new_action = "#{value}"
      form["action"] = new_action

      hidden_node = doc.create_element('input')
      hidden_node["name"] = "google_form"
      hidden_node["type"] = "hidden"
      hidden_node["value"] = original_action
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
  
  def submit(google_form_action, params)
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
