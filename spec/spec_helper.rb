begin
  require 'spec'
rescue LoadError
  require 'rubygems' unless ENV['NO_RUBYGEMS']
  gem 'rspec'
  require 'spec'
end

$:.unshift(File.dirname(__FILE__) + '/../lib')
require 'googletastic'

FIXTURES_DIR    = File.expand_path(File.join(File.dirname(__FILE__), 'fixtures')) unless defined?(FIXTURES_DIR)
MODELS_DIR      = File.join(FIXTURES_DIR, "models") unless defined?(MODELS_DIR)
DATA_DIR        = File.join(FIXTURES_DIR, "data") unless defined?(DATA_DIR)

$:.unshift(MODELS_DIR)
require 'test_model'

Googletastic::TestModel.send(:include, Googletastic::Helpers)
Dir.glob("#{MODELS_DIR}/*") {|file| require file}

Googletastic.keys = {
  :username => "flexinstyle@gmail.com",
  :password => "flexyflexy",
  :youtube_login => "MrFlexinstyle",
  :youtube_dev_key => "AI39si7jkhs_ECjF4unOQz8gpWGSKXgq0KJpm8wywkvBSw4s8oJd5p5vkpvURHBNh-hiYJtoKwQqSfot7KoCkeCE32rNcZqMxA"
}

NS              = Googletastic::Mixins::Namespaces::NAMESPACES