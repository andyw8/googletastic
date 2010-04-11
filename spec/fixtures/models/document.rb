class Document < Googletastic::TestModel
  googletastic :document,
    :as => :google_doc,
    :sync => :title
#  googletastic :doc_list
  attr_accessor :something
end