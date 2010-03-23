class Form < Googletastic::TestModel
  googletastic :form,
    :remote_id => :google_form_id,
    :sync => :title,
    :redirect_to => "/forms/:id"
end