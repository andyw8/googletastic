class Googletastic::Apps < Googletastic::Base
  
  class << self
    
    def new_url
      "http://www.google.com/a/cpanel/domain/new"
    end
    
    # follow_meta_refresh for FORMS!!!
    # might have to save cookiejar between requests as captcha is presented
    # domain, first_name, last_name, email, phone, country, username, password, password_confirmation
    def create(options = {})
      # precaptcha and postcaptcha
      agent = WWW::Mechanize.new
      page = agent.get(new_url)
      # fill out domain name (must already have)
      form = page.forms_with("domainEntry").first
      form.radiobuttons.first.check
      form.fields_with("existingDomain").first.value = options[:domain]
      second_page = agent.submit(form)
      # fill out profile
      form = second_page.forms.first
      form.firstName = options[:first_name]
      form.lastName = options[:last_name]
      form.email = options[:email]
      form.phone = options[:phone]
      #form.jobTitle = ""
      #form.orgName = ""
      # default value is "US"
      form.country = options[:country] || "US"
      # form.orgType = ""
      # form.orgSize
      # DO YOU AGREE???
      form.checkboxes_with("domainAdminCheck").first.check
      # third page must be filled out within about a minute it seems
      third_page = agent.submit(form)
      form = last_page.forms.first
      # sample CAPTCHA URL (or "format=audio")
      # form.captchaToken
      # https://www.google.com/a/cpanel/captcha?format=image&captchaToken=crazy-token
      form.captchaAnswer = "progshi"
      form.newUserName = options[:username]
      # minimum 6 chars
      form.fields_with("newPassword.alpha").first.value = options[:password]
      form.fields_with("newPassword.beta").first.value = options[:password_confirmation]
      last_page = agent.submit(form)

      # now you have your account
      form = last_page.forms_with(:action => "VerifyDomainOwnership").first
      form.radiobuttons_with(:value => "htmlVer").first.check

      verify_page = agent.submit(form)
      form = verify_page.forms_with(:action => "VerifyDomainOwnership") # or "id => 'verificationPages'"
      # upload file "googlehostedservice.html" with special text, and let google know it's okay
      special_text = verify_page.parser.xpath("//span[@class='callout']").first.text
      # upload to http://tinker.heroku.com/googlehostedservice.html
      apps_home = agent.submit(form)
    end
    
  end
  
end