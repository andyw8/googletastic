require 'rubygems'
require 'sinatra'
require File.join(File.dirname(__FILE__), "../lib/googletastic")

Googletastic.keys = YAML.load_file(File.expand_path("spec/config.yml")).symbolize_keys

set :public, "./"

get "/" do
  "<pre><code>#{Googletastic::Document.client.get("http://docs.google.com/View?docID=0Adytgc9GwEj3ZGd6d3A1eDNfMjc2Z3A1cnZrZnI&revision=_latest").to_xml.to_xml}</code></pre>"
end