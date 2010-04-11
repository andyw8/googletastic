module GData
  module Client
    
    # Client class to wrap working with the TBD App Engine API.
    class AppEngine < Base
      
      def initialize(options = {})
        options[:clientlogin_service] ||= 'ar'
        super(options)
      end
      
      # override so we can get cookie
      def get(url)
        set_cookie(url)
        response = self.make_request(:get, url)
        if response.status_code == 302
          # if it's redirecting us, we need to get the cookie
          new_cookie(url)
          # now we can make the request again
          response = self.make_request(:get, url)
        end
        response
      end
      
      def new_cookie(url)
        cookie = get_cookie(url)
        headers["Cookie"] = cookie
        Googletastic.credentials[:cookie] = cookie
        # save the cookie to a file since we're
        # not in the browser!
        File.open("config/gdata.yml", 'w') do |file|
          YAML.dump(Googletastic.credentials, file)
        end
        cookie
      end
      
      def get_cookie(url)
        uri = URI.parse(url)
        url_for_cookie = "#{uri.scheme}://#{uri.host}/_ah/login?continue=#{url}&auth=#{auth_handler.token}"
        response = c.get(url)
        cookie = response.headers["set-cookie"].split('; ',2)[0]
        cookie
      end
      
      def set_cookie(url)
        if Googletastic.credentials[:cookie]
          headers["Cookie"] = Googletastic.credentials[:cookie]
          return headers["Cookie"]
        else
          new_cookie(url)
        end
      end
      
      # globally push to google app engine, using the python library
      # pushes files to gae
      # required options:
      #   folder => where the python command executes
      #   username, password
      def push(username, password, options = {})
        options.symbolize_keys!
        raise "Please define local GAE Folder" unless options[:folder] and File.exists?(options[:folder])
        sleep 0.5
        # update GAE
        puts "Pushing to GAE..."
        cmd = "appcfg.py update #{options[:folder]}"
        original_values = [STDOUT.sync, STDERR.sync, $expect_verbose]
        STDOUT.sync     = true
        STDERR.sync     = true
        $expect_verbose = true
        PTY.spawn("#{cmd} 2>&1") do | input, output, pid |
          begin
            input.expect("Email:") do
              output.puts("#{username}\n")
            end
            input.expect("Password") do
              output.write("#{password}\n")
            end
            while ((str = input.gets) != nil)
              puts str
            end
          rescue Exception => e
            puts "GAE Error... #{e.inspect}"
          end
        end
        STDOUT.sync     = original_values[0]
        STDERR.sync     = original_values[1]
        $expect_verbose = original_values[2]
        sleep 0.5
      end
    end
  end
end

module Googletasic::AppEngine
  
end