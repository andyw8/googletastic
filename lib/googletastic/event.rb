class Googletastic::Event < Googletastic::Base
  
  attr_accessor :created_at, :updated_at, :title, :description
  attr_accessor :who, :start_time, :end_time, :where, :status, :comments
  attr_accessor :guests_can_join, :guests_can_invite, :guests_can_modify, :guests_can_see_guests, :sequence
  # not yet implemented
  attr_accessor :repeats, :calendar_id
  
  def new_record?
    return false if !self.id.nil?
    return true
    # not yet using this
    return self.class.first(:start_time => self.start_time, :end_time => self.end_time).nil?
  end  
    
  def edit_url
    self.class.edit_url(self.id)
  end
  
  class << self
    
    def client_class
      "Calendar"
    end
    
    def index_url
      "http://www.google.com/calendar/feeds/default/private/full"
    end
    
    def edit_url(id)
      "http://www.google.com/calendar/feeds/default/private/full/#{id}"
    end
    
    # http://code.google.com/apis/calendar/data/2.0/reference.html#Parameters
    # RFC 3339 timestamp format
    def valid_queries
      {
        :timezone => "ctz",
        :future_only => "futureevents",
        :order => "orderby",
        :collapse_recurring => "singleevents",
        :show_hidden => "showhidden",
        :before => "start-max",
        :after => "start-min",
        :sort => "sortorder" # should be merged with "order"
      }.merge(super)
    end
    
    def valid_order?(value)
      %w(lastmodified starttime).include?(value)
    end
    
    def valid_sort?(value)
      %w(ascending descending).include?(value)
    end
    
    def unmarshall(xml)
      records = xml.xpath("//atom:entry", ns_tag("atom")).collect do |record|
        id          = record.xpath("atom:id", ns_tag("atom")).first.text.split("/").last
        title       = record.xpath("atom:title", ns_tag("atom")).first.text
        description = record.xpath("atom:content", ns_tag("atom")).first.text
        created_at  = record.xpath("atom:published", ns_tag("atom")).first.text
        updated_at  = record.xpath("atom:updated", ns_tag("atom")).first.text
        
        status      = record.xpath("gd:eventStatus", ns_tag("gd")).first["value"].gsub("http://schemas.google.com/g/2005#event.", "")
        where       = record.xpath("gd:where", ns_tag("gd")).first["valueString"].to_s
        
        who         = record.xpath("gd:who", ns_tag("gd")).collect do |who|
          Googletastic::Attendee.new(
            :name => who["valueString"].to_s,
            :email => who["email"],
            :role => who["rel"].gsub("http://schemas.google.com/g/2005#event.", "")
          )
        end

        time        = record.xpath("gd:when", ns_tag("gd")).first
        start_time  = time["startTime"].to_s
        end_time    = time["endTime"].to_s
        
        guests_can_join     = record.xpath("gCal:anyoneCanAddSelf", ns_tag("gCal")).first["value"] == "true" ? true : false
        guests_can_invite   = record.xpath("gCal:guestsCanInviteOthers", ns_tag("gCal")).first["value"] == "true" ? true : false
        guests_can_modify   = record.xpath("gCal:guestsCanModify", ns_tag("gCal")).first["value"] == "true" ? true : false
        guests_can_see_guests = record.xpath("gCal:guestsCanSeeGuests", ns_tag("gCal")).first["value"] == "true" ? true : false
        sequence            = record.xpath("gCal:sequence", ns_tag("gCal")).first["value"].to_i
        
        Googletastic::Event.new(
          :id => id,
          :title => title,
          :description => description,
          :created_at => created_at,
          :updated_at => updated_at,
          :status => status,
          :where => where,
          :who => who,
          :start_time => start_time,
          :end_time => end_time,
          :guests_can_join => guests_can_join,
          :guests_can_invite => guests_can_invite,
          :guests_can_modify => guests_can_modify,
          :guests_can_see_guests => guests_can_see_guests,
          :sequence => sequence
        )
      end
      records
    end
    
    def marshall(record)
      Nokogiri::XML::Builder.new { |xml| 
        xml.entry(ns_xml("atom", "gCal", "gd")) {
          if record.id
            xml.id_ {
              xml.text record.id
            }
          end
          if record.created_at
            xml.published {
              xml.text record.created_at
            }
          end
          if record.updated_at
            xml.updated {
              xml.text record.updated_at
            }
          end
          xml.title {
            xml.text record.title
          }
          xml.content {
            xml.text record.description
          }
          record.who.each do |who|
            xml["gd"].who(
              :email => who.email, 
              :rel => "http://schemas.google.com/g/2005#event.#{who.role}",
              :valueString => who.name
            ) {
              xml["gd"].attendeeStatus(:value => "http://schemas.google.com/g/2005#event.#{record.status}")
            }
          end unless record.who.nil?
          xml["gd"].where("valueString" => record.where)
          
          xml["gd"].when("startTime" => record.start_time, "endTime" => record.end_time)
        }
      }.to_xml
    end
    
  end
  
end