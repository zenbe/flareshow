class Flareshow::Resource
  
  class << self
    # return the resource key for this resource
    def resource_key
      Flareshow::ClassToResourceMap[self.name]
    end
    
    # find an existing instance of this object in the client or create a new one
    def get_from_cache(id)
      store.get_resource(resource_key, id)
    end
    
    # list out the instances in memory
    def list_cache
      store.list_resource(resource_key)
    end
    
    # store the response resources in the cache
    def cache_response(response)
      Flareshow::CacheManager.assimilate_resources(response["resources"])
    end
  
    # find a resource by querying the server
    # store the results in the cache and return
    # the keyed resources for the model performing the query
    def find(params={})
      response = Flareshow::Service.query({resource_key => params})
      cache_response(response)
      (response["resources"] || {})[resource_key]
    end

    # create a resource local and sync it to the server
    def create(params={})
      new(params).save
    end
    
    #
    def store
      Flareshow::CacheManager.cache
    end
  end
  
  # constructor
  # build a new Flareshow::Base resource
  def initialize(data={}, source = :client)
    @data = {}
    data["id"] = UUID.generate.upcase if source == :client
    update(data, source)
  end
  
  # return the resource key for this resource
  def resource_key
    Flareshow::ClassToResourceMap[self.class.name]
  end
  
  # store a resource in the cache
  def cache
    self.class.store.store.set_resource(resource_key, id, self)
  end
  
  # ==============================
  # = Server Persistence Actions =
  # ==============================
  
  # reload the resource from the server
  def refresh
    results = self.find({"id" => id})
    mark_destroyed! if results.empty?
    self
  end
  
  # save a resource to the server
  def save
    key = Flareshow::ClassToResourceMap[self.class.name]
    response = Flareshow::Service.commit({resource_key => [(self.changes || {}).merge({"id" => id})] })
    cache_response(response)
    self
  end
  
  # destroy the resource on the server
  def destroy
    response = self.class.commit({resource_key => [{"id" => id, "_removed" => true}]})
    cache_response(response)
    mark_destroyed!
    self
  end
  
  # has this resource been destroyed
  def destroyed?
    self._removed || self.frozen?
  end
  
  private
  
  def mark_destroyed!
    self.freeze
    self._removed=true 
    self.class.store.delete(id)
  end
  
  public
  
  # ==================================
  # = Attribute and State Management =
  # ==================================
  
  # return the server id of a resource
  def id
    @data["id"]
  end
  
  # update the instance data for this resource
  # keeping track of dirty state if the update came from
  # the client
  def update(attributes, source = :client)
    attributes.each do |p|
      key, value = p[0], p[1]
      self.set(key, value, source)
    end
  end
  
  # keep track of dirty state on the client by maintaining a copy
  # of the original state of each intstance variable when it is provided by
  # the server
  def set(key, value, source = :client)
    # Flareshow::Util.log_info("setting #{key} : #{value}")
    @data["original_#{key}"] = value if source == :server
    @data[key.to_s]=value
  end
  
  # get a data value
  def get(key)
    @data[key]
  end
  
  # all the state that has been modified on the client
  def changes
    attributes = @data.inject({}) do |memo, pair|
      key, value = *pair
      if @data[key] != @data["original_#{key}"] && !key.to_s.match(/original/)
        memo[key] = value
      end
      memo
    end
  end
  
  # fallback to getter or setter
  def method_missing(meth, *args)
    meth = meth.to_s
    meth.match(/\=/) ? set(meth.gsub(/\=/,''), *args) : get(meth)
  end
  
  # has this model been removed on the server
  def method_name
    !!self._removed
  end
  
end