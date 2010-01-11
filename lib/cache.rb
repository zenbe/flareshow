# provides an interface for various
# caches that flareshow might use
class Flareshow::CacheManager
  
  class << self
    # assimilate the resources provided in the response
    def assimilate_resources(data)
      # process each resource key and generate a new object
      # or merge the object data with an existing object
      data.inject({}) do |memo,resource_pair|
        resource_key, resources = resource_pair[0], resource_pair[1]
        
        fs_resource_array = memo[resource_key] ||= []
        klass_name = Flareshow::ResourceToClassMap[resource_key]
        klass = Kernel.const_get(klass_name)
        if klass_name
          if klass
            resources.each do |resource_data|
              item = cache.get_resource(resource_key, resource_data["id"])
              if item
                item.update(resource_data, :server)
              else
                item = klass.new(resource_data, :server) 
              end
              cache.set_resource(resource_key, item.id, item)
              fs_resource_array << item
            end
          end
        end
        memo
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
    
    # you can create your own cache object and plug it into the cache manager.
    # The cache class should implement the public methods 
    # get_resource, set_resource, delete_resource, list_resource, flush and size
    
    # load a resource from the cache
    def get_resource(resource_key, id)
      resource_cache(resource_key)[id]
    end
    
    # set a resource in the cache
    def set_resource(resource_key, id, object)
      resource_cache(resource_key)[id] = object
    end
    
    # remove a resource
    def delete_resource(resource_key, id)
      resource_cache(resource_key).delete(id)
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