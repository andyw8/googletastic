module Googletastic::Mixins::Finders
  
  def self.included(base)
    base.extend(ClassMethods)
  end
  
  module ClassMethods
    def first(*args)
      find(:first, *args)
    end
    
    def last(*args)
      find(:last, *args)
    end
    
    def all(*args)
      find(:all, *args)
    end
    
    def find(*args)
      options = args.extract_options!

      case args.first
        when :first then find_initial(options)
        when :last  then find_last(options)
        when :all   then find_every(options)
        else             find_from_ids(args, options)
      end
    end

    def find_initial(options)
      find_by_api(options.merge({:limit => 1})).first
    end
    
    def find_last(options)
      
    end
    
    def find_every(options)
      find_by_api(options)
    end

    def find_from_ids(ids, options)
      expects_array = ids.first.kind_of?(Array)
      return ids.first if expects_array && ids.first.empty?
      
      ids = ids.flatten.compact.uniq
      
      case ids.size
        when 0
          raise RecordNotFound, "Couldn't find #{name} without an ID"
        when 1
          result = find_one(ids.first, options)
          expects_array ? [ result ] : result
        else
          find_some(ids, options)
      end
    end
    
    def find_one(id, options)
      options[:id] = id
      find_by_api(options)
    end

    def find_some(ids, options)
      
    end
    
    def find_by_api(options)
      url = build_url(options)
      agent = options.has_key?(:client) ? options[:client] : client
      data = agent.get(url)
      return data if options.has_key?(:raw) and options[:raw] == true
      records = unmarshall(data.to_xml)
    end
  end
  
end