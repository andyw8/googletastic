class Form < Googletastic::TestModel
  googletastic :form, :form_only => true, :action => /asdf/
end