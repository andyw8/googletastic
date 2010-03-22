# from http://github.com/mocra/custom_google_forms
class Googletastic::Form < Googletastic::Base
  
  attr_accessor :title, :body
  
  class << self
    
    def form_url(id)
      "http://spreadsheets.google.com/viewform?formkey=#{id}"
    end
    
    # there is no form api :/
    def find_by_api(options)
      record = fetch_form_page(options[:entryID])
    end
    
    def unmarshall(html)
      id = html.xpath("//form").first["action"].to_s.gsub("http://spreadsheets.google.com/formResponse?formkey=", "")
      title = html.xpath("//h1[@class='ss-form-title']").first.text
      body = content(html)
      Googletastic::Form.new(
        :id => id,
        :title => title, 
        :body => body.to_html
      )
    end
    
    def fetch_form_page(id)
      uri = URI.parse(form_url(id))
      req = Net::HTTP::Get.new("#{uri.path}?#{uri.query}")
      response = Net::HTTP.new(uri.host).start {|h| h.request(req)}
      return response.is_a?(Net::HTTPSuccess) ? unmarshall(Nokogiri::HTML(response.body)) : response
    end
    
    def content(form_html, &block)
      doc = form_html
      #google_form = form.xpath("//form").first.unlink
      doc.xpath("//*[@class='ss-footer']").first.unlink
      doc.xpath("//div[@class='ss-form-container']").first.unlink
    end
    
  end
  
  def submit(google_form_action, params)
    uri = URI.parse(google_form_action)
    req = Net::HTTP::Post.new("#{uri.path}?#{uri.query}")
    req.form_data = params
    response = Net::HTTP.new(uri.host).start {|h| h.request(req)}
    response
  end
  
  def to_rails_form
    form = Nokogiri::HTML(self.body)
    put_node = form.create_element('input')
    put_node["name"] = "_method"
    put_node["type"] = "hidden"
    put_node["value"] = "put"
    form.children.first.add_previous_sibling(put_node)
    
    css_node = form.create_element('link')
    css_node["href"] = "/stylesheets/reset.css"
    css_node["rel"] = "stylesheet"
    css_node["type"] = "text/css"
    form.xpath("//head").first.add_child(css_node)
    
    css_node = doc.create_element('link')
    css_node["href"] = "/stylesheets/style.css"
    css_node["rel"] = "stylesheet"
    css_node["type"] = "text/css"
    doc.xpath("//head").first.add_child(css_node)

    footer = doc.create_element('div')
    footer["id"] = "footer"
    doc.xpath("//body").first.add_child(footer)

    analytics = doc.create_element('div')
    #analytics.inner_html = render_to_string :partial => 'shared/google_analytics'
    doc.xpath("//body").first.add_child(analytics)
    doc = doc.xpath("//div[@class='ss-form-container']").first
    doc
  end
  
  def view_url
    "http://spreadsheets.google.com/viewform?formkey=#{id}"
  end
end
