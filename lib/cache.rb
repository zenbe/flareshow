# provides an interface for various
# caches that flareshow might use
class Flareshow::CacheManager
  
  class << self
    # assimilate the resources provided in the response
    def assimilate_resources(data)
      # process each resource key and generate a new object
      # or merge the object data with an existing object
      data.each do |resource_pair|
        resource_key, resources = resource_pair[0], resource_pair[1]
        klass = Kernel.const_get(Flareshow::ResourceToClassMap[resource_key])
        next unless klass
        resources = resources.map do |resource_data|
          item = cache.get_resource(resource_key, resource_data["id"])
          if item
            item.update(resource_data, :server)
          else
            item = klass.new(resource_data, :server) 
          end
          cache.set_resource(resource_key, item.id, item)
          item
        end
      end
    end
    
    # get the managed cache object
    def cache
      @cache ||= Flareshow::Cache.new
    end
    
  end
  
  
end

# a simple in memory cache for Flareshow objects
class Flareshow::Cache
    
    # load a resource from the cache
    def get_resource(resource_key, id)
      resource_cache(resource_key)[id]
    end
    
    # set a resource in the cache
    def set_resource(resource_key, id, object)
      resource_cache(resource_key)[id] = object
    end
    
    def list_resource(resource_key)
      resource_cache(resource_key)
    end
    
    # remove all cached objects
    def flush
      data = {}
    end
    
    # number of cached objects
    def size
      data.values.inject(0){|m,v| m+=v.size}
    end
    
    private
    # data store for the cache
    def data
      @cache ||= {}
    end
    
    # get a specific resource dictionary
    def resource_cache(resource_key)
      data[resource_key] ||= Dictionary.new
    end
    
end