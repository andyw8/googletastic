module Googletastic::Helpers::Form
  
  # class options for Form:
  #   as: property name for the googletastic form
  #   foreign_key: foreign key to reference it, defaults to "as"_id
  #   sync: the properties you want to sync with the form
  #   redirect_to: where to redirect the forms submission
  def self.included(base)
    # defaults
    options = Googletastic[base]
    options[:as] ||= "google_form"
    options[:foreign_key] ||= "#{options[:as]}_id"
    if options.has_key?(:sync)
      if options[:sync].is_a?(Symbol)
        options[:sync] == {options[:sync] => options[:sync]}
      elsif options[:sync].is_a?(String)
        options[:sync] = {options[:sync].to_sym => options[:sync].to_sym}
      elsif options[:sync].is_a?(Array)
        options[:sync] = options[:sync].collect { |v| {v.to_sym => v.to_sym} }
      else
        options[:sync].symbolize_keys!
      end
    end

    # eval
    base.class_eval <<-"end_eval", __FILE__, __LINE__
      def find_via_#{Googletastic[self][:as]}(*args)
        google_records = Googletastic::Form.find(*args)
        foreign_keys = google_records.collect { |record| record.id }
        records = find(foreign_keys)
        record_keys = records.collect do |record|
          record["\#\{Googletastic[self][:foreign_key]\}"]
        end
        foreign_keys.each do |key|
          if !record_keys.include?(key)
            records << self.class.new(:"\#\{Googletastic[self][:foreign_key]\}" => key)
          end
        end
        records
      end
    end_eval
    
    base.class_eval do
      attr_accessor :"#{Googletastic[self][:as]}"
      
      if base.is_a?(ActiveRecord::Base)
        before_validation       :clean_form_key
        validates_presence_of   :form_key
        validates_uniqueness_of :form_key
        validate :validate_formkey_is_valid
        before_save :sync_with_google
        
        def sync_with_google
          Googletastic[self].each do |mine, theirs|
            self[mine] = self["#{Googletastic[self][:method_name]}"][theirs]
          end if Googletastic[self].has_key?(:sync)
        end
        
        def clean_form_key
          if self["#{Googletastic[self][:method_name]}"].form_key =~ /=(.*)$/
            #{Googletastic[self][:method_name]}.form_key = $1
          end
        end
        
        def validate_form_key_is_valid
          case fetch_form_page
          when Net::HTTPSuccess
            true
          else
            errors.add(:form_key, "is not a valid Google Forms key or URL or error connecting to Google")
            false
          end
        end
      end
    end
  end
  
end