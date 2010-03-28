begin
  require 'spec'
rescue LoadError
  require 'rubygems' unless ENV['NO_RUBYGEMS']
  gem 'rspec'
  require 'spec'
end
require 'benchmark'

$:.unshift(File.dirname(__FILE__) + '/../lib')
require 'googletastic'

FIXTURES_DIR    = File.expand_path(File.join(File.dirname(__FILE__), 'fixtures')) unless defined?(FIXTURES_DIR)
MODELS_DIR      = File.join(FIXTURES_DIR, "models") unless defined?(MODELS_DIR)
DATA_DIR        = File.join(FIXTURES_DIR, "data") unless defined?(DATA_DIR)

$:.unshift(MODELS_DIR)
require 'test_model'

Googletastic::TestModel.send(:include, Googletastic::Helpers)
Dir.glob("#{MODELS_DIR}/*") {|file| require file}

Googletastic.keys = YAML.load_file("spec/config.yml").symbolize_keys

NS              = Googletastic::Mixins::Namespaces::NAMESPACES