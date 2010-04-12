# from http://github.com/mocra/custom_google_forms
class Googletastic::Form < Googletastic::Base
  
  attr_accessor :title, :body, :redirect_to, :form_key, :form_only
  
  def body(options = {}, &block)
    @body ||= get(options, &block)
    @body
  end
  
  def submit_url
    self.class.submit_url(self.form_key)
  end
  
  def show_url
    self.class.show_url(self.form_key)
  end
  
  class << self
    
    def client_class
      "Spreadsheets"
    end
    
    def index_url
      "http://spreadsheets.google.com/feeds/spreadsheets/private/full"
    end
    
    def submit_url(id = "")
      "http://spreadsheets.google.com/formResponse?formkey=#{id}"
    end
    
    def show_url(id)
      "http://spreadsheets.google.com/viewform?formkey=#{id}"
    end
    
    def unmarshall(xml)
      records = xml.xpath("//atom:entry", ns_tag("atom")).collect do |record|
        id          = record.xpath("atom:id", ns_tag("atom")).first.text.gsub("http://spreadsheets.google.com/feeds/spreadsheets/", "")
        title       = record.xpath("atom:title", ns_tag("atom")).first.text
        created_at  = record.xpath("atom:published", ns_tag("atom")).text
        updated_at  = record.xpath("atom:updated", ns_tag("atom")).text
        
        # same as spreadsheet
        Googletastic::Form.new(
          :id => id,
          :title => title,
          :updated_at => DateTime.parse(updated_at)
        )
      end
      records
    end
    
  end
  
  def submit(form_key, params)
    action = submit_url(form_key)
    uri = URI.parse(action)
    req = Net::HTTP::Post.new("#{uri.path}?#{uri.query}")
    req.form_data = params
    response = Net::HTTP.new(uri.host).start {|h| h.request(req)}
    response
  end
  
  # get(:redirect => {:url => "/our-forms", :params => {:one => "hello"}})
  def get(options = {}, &block)
    raise "I NEED A FORM KEY!" unless self.form_key
    response = client.get(show_url)
    if response.is_a?(Net::HTTPSuccess) || response.is_a?(GData::HTTP::Response)
      unmarshall(Nokogiri::HTML(response.body), options, &block)
    else
      response
    end
  end
  
  # not class unmarshall, instance unmarshall
  def unmarshall(html, options, &block)
#    title = html.xpath("//h1[@class='ss-form-title']").first.text
    add_redirect(html, options, &block)
    
    if self.form_only
      html.xpath("//form").first.unlink
    else
      html.xpath("//div[@class='ss-footer']").first.unlink
      html.xpath("//div[@class='ss-form-container']").first.unlink
    end
  end
  
  def add_redirect(doc, options, &block)
    action = doc.xpath("//form").first["action"].to_s
    submit_key = action.gsub(self.submit_url, "")
    
    form = doc.xpath("//form").first
    
    form["enctype"] = "multipart/form-data"      
    
    # don't have time to build this correctly
    redirect = options[:redirect] || self.redirect_to
    if redirect
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