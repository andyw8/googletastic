require 'rubygems'
require 'rake'
require 'date'
require 'rake/clean'
#require 'rbconfig'
require 'open-uri'
require 'nokogiri'
require 'active_support'
require 'active_record'
require 'gdata'
require 'liquid'

GOOGLETASTIC_ROOT = "#{File.dirname(__FILE__)}/.." unless defined?(GOOGLETASTIC_ROOT)

class Module
  def include_class_and_instance_modules
    self.module_eval <<-eos 
      def self.included(base)
        base.extend(ClassMethods)
        base.class_eval do
          include InstanceMethods
        end
      end
    eos
  end
end

def require_local(path, from = __FILE__)
  files(path, from) {|file| require file}
end

def files(path, from = __FILE__, &block)
  Dir.glob(File.expand_path(File.join(File.dirname(from), path))) {|file| yield file}
end

def require_spec
  require File.join(GOOGLETASTIC_ROOT, "/spec/spec_helper")
end

module Googletastic
  # :stopdoc:
  VERSION = '0.0.1'
  # :startdoc
  class << self; attr_accessor :keys, :clients, :options; end

  def self.credentials
    return self.keys if self.keys
    
    config_file = "#{RAILS_ROOT}/config/gdata.yml"
    raise "Sorry, you must have #{config_file}" unless File.exists?(config_file)
    self.keys = YAML.load_file(config_file).symbolize_keys
  end

  def self.client_for(model)
    self.clients ||= {}
    model = model.to_sym
    return self.clients[model] if self.clients.has_key?(model)
	  client = ("GData::Client::#{model.to_s.camelize}").constantize.new(:source => credentials[:application])
	  client.clientlogin(credentials[:username], credentials[:password], nil, nil, nil, credentials[:account_type])	  
	  self.clients[model] = client
  end
  
  def self.options_for(klass, value = {})
    self.options ||= {}
    klass = klass.is_a?(Class) ? klass : klass.class
    name = klass.to_s.underscore.downcase.to_sym
    if value and !value.blank?
      value.symbolize_keys!
      self.options[name] = value
    else
      self.options[name] ||= {}
    end
    self.options[name]
  end
  
  def self.[](value)
    self.options_for(value)
  end
end

# main includes
require_local "googletastic/ext/*"

require File.dirname(__FILE__) + '/googletastic/mixins'
require File.dirname(__FILE__) + '/googletastic/base'

require_local "googletastic/*"

#files("googletastic/mixins/*") do |file|
#  Googletastic::Base.send(:include, "Googletastic::Mixins::#{File.basename(file, '.rb').camelize}".constantize)
#end

if defined?(ActiveRecord::Base)
  ActiveRecord::Base.send(:include, Googletastic::Helpers)
end
# EOF