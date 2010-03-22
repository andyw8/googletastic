require 'rubygems'
require 'rake'
require 'rake/clean'
#require 'rbconfig'
require 'nokogiri'
require 'active_support'
require 'active_record'
require 'gdata'

GOOGLETASTIC_ROOT = "#{File.dirname(__FILE__)}/.." unless defined?(GOOGLETASTIC_ROOT)

def require_local(path, from = __FILE__)
  files(path, from) {|file| require file}
end

def files(path, from = __FILE__, &block)
  Dir.glob(File.join(File.dirname(from), path)) {|file| yield file}
end

def require_spec
  require File.join(GOOGLETASTIC_ROOT, "/spec/spec_helper")
end

module Googletastic
  # :stopdoc:
  VERSION = '0.0.1'
  # :startdoc
  class << self; attr_accessor :keys, :clients end

  def self.credentials
    return self.keys if self.keys

    config_file = "#{APP_ROOT}/config/gdata.yml"
    raise "Sorry, you must have #{config_file}" unless File.exists?(config_file)
    self.keys = YAML.load_file(config_file).symbolize_keys
  end

  def self.client_for(model)
    self.clients ||= {}
    model = model.to_sym
    return self.clients[model] if self.clients.has_key?(model)
	  client = ("GData::Client::#{model.to_s.camelize}").constantize.new
	  client.clientlogin(credentials[:username], credentials[:password])
	  self.clients[model] = client
  end
end

# main includes
require File.dirname(__FILE__) + '/googletastic/mixins'
require File.dirname(__FILE__) + '/googletastic/base'

files("googletastic/mixins/*") do |file|
  Googletastic::Base.send(:include, "Googletastic::Mixins::#{File.basename(file, '.rb').camelize}".constantize)
end

require_local "googletastic/*"

if defined?(ActiveRecord::Base)
  ActiveRecord::Base.send(:include, Googletastic::Helpers)
end
# EOF