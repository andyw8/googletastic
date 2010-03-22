class Document < Googletastic::TestModel
  googletastic :doc_list
  attr_accessor :something
end