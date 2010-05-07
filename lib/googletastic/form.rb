# from http://github.com/mocra/custom_google_forms
class Googletastic::Form < Googletastic::Base
  
  FORM_KEY_EXPRESSION = /formkey["|']\s*:["|']\s*([^"|']+)"/ unless defined?(FORM_KEY_EXPRESSION)
  
  attr_accessor :title, :body, :redirect_to, :form_key, :form_only, :authenticity_token
  
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
        #id          = record.xpath("atom:id", ns_tag("atom")).first.text.gsub("http://spreadsheets.google.com/feeds/spreadsheets/", "")
        id          = record.xpath("atom:link[@rel='alternate']", ns_tag("atom")).first
        if id
          id = id["href"].gsub("http://spreadsheets.google.com/ccc?key=", "")
        end
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
  
  def get_form_key
    begin
      agent = defined?(Mechanize) ? Mechanize.new : WWW::Mechanize.new
      # google wants recent browsers!
      # http://docs.google.com/support/bin/answer.py?answer=37560&hl=en
      agent.user_agent = "Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10_6_2; ru-ru) AppleWebKit/533.2+ (KHTML, like Gecko) Version/4.0.4 Safari/531.21.10"
      url = "http://spreadsheets.google.com/"
      # for spreadsheet, we need the domain!
      if Googletastic.credentials[:domain]
        url << "a/#{Googletastic.credentials[:domain]}/"
      end
      url << "ccc?key=#{self.id}&hl=en&pli=1"
      login_form = agent.get(url).forms.first
      login_form.Email = Googletastic.credentials[:username].split("@").first # don't want emails
      login_form.Passwd = Googletastic.credentials[:password]
      page = agent.submit(login_form)
      match = page.body.match(FORM_KEY_EXPRESSION)
      if page.meta.first and (page.title == "Redirecting" || match.nil?)
      	page = page.meta.first.click
        match = page.body.match(FORM_KEY_EXPRESSION)
      end
      formkey = match.captures.first if match
    rescue Exception => e
      puts "ERROR: #{e.to_s}"
      nil
    end
  end
  
  def submit(form_key, params, options)
    uri = URI.parse(submit_url)
    req = Net::HTTP::Post.new("#{uri.path}?#{uri.query}")
    req.form_data = params
    response = Net::HTTP.new(uri.host).start {|h| h.request(req)}
    if response.is_a?(Net::HTTPSuccess) || response.is_a?(GData::HTTP::Response)
      unmarshall(Nokogiri::HTML(response.body), options).to_html
    else
      response.body
    end
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
    
    html.xpath("//textarea").each do |node|
      node.add_child Nokogiri::XML::Text.new("\n", html)
    end
    
    if self.form_only
      html.xpath("//form").first.unlink
    else
      html.xpath("//div[@class='ss-footer']").first.unlink
      html.xpath("//script").each {|x| x.unlink }
      html.xpath("//div[@class='ss-form-container']").first.unlink
    end
  end
  
  def add_redirect(doc, options, &block)
    action = doc.xpath("//form").first
    return if action.nil?
    action = action["action"].to_s
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