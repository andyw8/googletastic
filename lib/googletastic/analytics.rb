module Googletastic::Analytics
  # https://www.google.com/accounts/ServiceLoginBox?service=analytics&nui=1&hl=en-US&continue=https://www.google.com/analytics/settings/?et=reset&hl=en&et=reset&hl=en-US
  
  def create(options = {})
    agent = WWW::Mechanize.new
    agent.cookie_jar.load(options[:cookies])
    scid = "15601175" # one of the options options[:profile]
    form.fields_with("scid").first.value = scid
    next_page = agent.submit(form)
    new_analytics = "https://www.google.com/analytics/settings/add_profile?scid=#{scid}"
    # ucpr_protocol
    form = next_page.forms_with(:name => "mform").first
    form.ucpr_url = options[:domain]
    tracking = agent.submit(form)
    tracking_code = tracking.parser.xpath("//script").to_s.match(/getTracker\(["|']([^"|']+)["|']\)/).captures.first
  end
  
  # returns an array of account names you can use
  def login(options = {})
    agent = WWW::Mechanize.new
    url = "https://www.google.com/accounts/ServiceLoginBox?service=analytics&nui=1&hl=en-US&continue=https://www.google.com/analytics/settings/?et=reset&hl=en&et=reset&hl=en-US"
    page = agent.get(url)
    login_form = page.forms.first
    login_form.Email = options[:email]
    login_form.Passwd = options[:password]

    # agent.cookie_jar.save_as("something.yml")
    
    next_page = agent.submit(login_form)
    home = next_page.links.first.click
    
    form = home.forms_with("account_selector").first
  end
end