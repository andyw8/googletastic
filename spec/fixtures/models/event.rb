class Event < Googletastic::TestModel
  googletastic :event, :foreign_key => :g_event
end