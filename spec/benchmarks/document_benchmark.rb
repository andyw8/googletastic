require 'benchmark'
require 'rubygems'

$:.unshift(File.dirname(__FILE__) + '/..')
require 'spec_helper'

id = "0AT1-fvkm5vJPZGN2NzR3bmJfMGZiMnh3N2R0"
many = 1

Benchmark.bmbm(7) do |x|
  x.report ("Find the Document") do
    many.times do |i|
      doc = Googletastic::Document.find(id)
    end
  end
  x.report("View the Raw HTML: ") do
    many.times do |i|
      doc = Googletastic::Document.find(id)
      result = doc.view
    end
  end
  x.report("Download as HTML: ") do
    many.times do |i|
      doc = Googletastic::Document.find(id)
      result = doc.download("html")
    end
  end
  x.report("Download as TXT: ") do
    many.times do |i|
      doc = Googletastic::Document.find(id)
      result = doc.download("txt")
    end
  end
  x.report("Download as PDF: ") do
    many.times do |i|
      doc = Googletastic::Document.find(id)
      result = doc.download("pdf")
    end
  end
end