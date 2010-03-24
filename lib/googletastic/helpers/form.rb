# was Googletastic::Helpers::Form, but rails through fits with namespacing problems
module Googletastic::Helpers::FormModelHelper
  
  # REQUIREMENTS:
  # DEFINE 'formkey' property on model
  
  # class options for Form:
  #   as: property name for the googletastic form
  #   foreign_key: foreign key to reference it, defaults to "as"_id
  #   sync: the properties you want to sync with the form
  #   redirect_to: where to redirect the forms submission
  #   form_only: don't include title and header that google gives you (defaults to false)
  def self.included(base)
    # defaults
    options = Googletastic[base]
    options[:as] ||= "google_form"
    options[:foreign_key] ||= "#{options[:as]}_id"
    options[:form_key] ||= "form_key"
    options[:form_only] = false unless options.has_key?(:form_only)
    if options.has_key?(:sync)
      options[:sync] = case options[:sync].class.to_s
        when "Symbol"
          {options[:sync] => options[:sync]}
        when "String"
          {options[:sync].to_sym => options[:sync].to_sym}
        when "Array"
          options[:sync].collect { |v| {v.to_sym => v.to_sym} }
        else
          options[:sync].symbolize_keys
        end
    end
    
    Googletastic::Form.redirect_to = options[:redirect_to] if options.has_key?(:redirect_to)
    Googletastic::Form.form_only = options[:form_only]
    
    # fast access
    as          = options[:as]
    foreign_key = options[:foreign_key]
    sync        = options[:sync]
    form_key    = options[:form_key]
    
    # eval
    base.class_eval <<-end_eval, __FILE__, __LINE__
      attr_accessor :#{as}
      
      def self.find_with_#{as}(*args)
        google_records = Googletastic::Form.all
        foreign_keys = google_records.collect { |record| record.id }
        records = find_all_by_#{foreign_key}(foreign_keys) || []
        record_keys = records.collect { |record| record.#{foreign_key} }
        google_records.each do |google_record|
          if !record_keys.include?(google_record.id)
            record = self.new(
              :#{foreign_key} => google_record.id,
              :title => google_record.title
            )
            record.save
            records << record
          end
        end
        records
      end
      
      def #{as}
        @#{as} ||= Googletastic::Form.new(
          :id => self.#{foreign_key},
          :title => self.title,
          :form_key => self.#{form_key}
        )
        @#{as}
      end
      
      # get form content
      def get
        self.#{as}.form_key ||= self.#{form_key}
        self.#{as}.get
      end
      
      if base.is_a?(ActiveRecord::Base)

          before_validation       :clean_form_key
          validates_presence_of   :#{as}
          validates_uniqueness_of :#{as}
          validate                :validate_formkey_is_valid
          before_save             :sync_with_google

          def sync_with_google
            Hash(#{sync}).each do |mine, theirs|
              self[mine] = self.#{as}[theirs]
            end if Googletastic[self].has_key?(:sync)
          end

          def validate_form_key_is_valid
            case self.#{as}.get
            when Net::HTTPSuccess
              true
            else
              errors.add(:form_key, "is not a valid Google Forms key or URL or error connecting to Google")
              false
            end
          end

      end
    end_eval
  end
  
end