module Googletastic::Helpers::DocumentModelHelper
  
  def self.included(base)
    # defaults
    options = Googletastic[base]
    options[:as] ||= "google_doc"
    options[:foreign_key] ||= "#{options[:as]}_id"
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
    
    # fast access
    as          = options[:as]
    foreign_key = options[:foreign_key]
    sync        = options[:sync]
    
    # eval
    base.class_eval <<-end_eval, __FILE__, __LINE__
      attr_accessor :#{as} # google_doc
      attr_accessor :content
      
      def self.find_with_#{as}(*args)
        google_records = Googletastic::Document.all
        foreign_keys = google_records.collect { |record| record.id }
        records = find_all_by_#{foreign_key}(foreign_keys) || []
        record_keys = records.collect { |record| record.#{foreign_key} }
        google_records.each do |google_record|
          if !record_keys.include?(google_record.id)
            record = self.new(
              :#{foreign_key} => google_record.id,
              :created_at => google_record.created_at,
              :updated_at => google_record.updated_at,
              :#{as} => google_record,
              :title => google_record.title
            )
            record.save
            records << record
          end
        end
        records.each do |record|
          record.#{as} = google_records.select { |r| r.id == record.#{foreign_key} }.first
        end
        records
      end
      
      if base.is_a?(ActiveRecord::Base)

        validates_presence_of   :#{foreign_key}
        validates_uniqueness_of :#{foreign_key}
        before_save             :sync_with_google
        
        def sync_with_google
          Hash(#{sync}).each do |mine, theirs|
            self[mine] = self.#{as}[theirs]
          end if Googletastic[self].has_key?(:sync)
        end

      end
    end_eval
  end
end