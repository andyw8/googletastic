class Form < Googletastic::TestModel
  googletastic :form,
    :as => :google_form,
    :sync => :title,
    :redirect_to => "/forms/:id"
end