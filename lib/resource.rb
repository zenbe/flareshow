class Flareshow::Resource
  
  class << self
    attr_accessor :read_only, :attr_accessible, :attr_required
    
    def default_params
      # default parameters that are included with query
      # requests unless they are explicitly overridden
      {:order => "created_at desc"}
    end
    
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
      params = default_params.merge(params)
      response = Flareshow::Service.query({resource_key => params})
      (cache_response(response) || {})[resource_key]
    end
    
    # find just one resource matching the conditions specified
    def first(params={})
      params = default_params.merge(params)
      params = params.merge({"limit" => 1})
      response = Flareshow::Service.query({resource_key => params})
      (cache_response(response) || {})[resource_key].first
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
    Flareshow::Util.log_info("creating #{self.class.name} with data from #{source}")
    update(data, source)
    @data["id"] = UUID.generate.upcase if source == :client
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
    raise Flareshow::APIAccessException if self.class.read_only
    key = Flareshow::ClassToResourceMap[self.class.name]
    raise Flareshow::MissingRequiredField unless !self.class.attr_required || (self.class.attr_required.map{|a|a.to_s} - @data.keys).empty?
    response = Flareshow::Service.commit({resource_key => [(self.changes || {}).merge({"id" => id})] })
    cache_response(response)
    self
  rescue Exception => e
    Flareshow::Util.log_error e.message
    throw e
    false
  end
  
  # destroy the resource on the server
  def destroy
    raise Flareshow::APIAccessException if self.class.read_only
    response = Flareshow::Service.commit({resource_key => [{"id" => id, "_removed" => true}]})
    cache_response(response)
    mark_destroyed!
    self
  rescue Exception => e
    Flareshow::Util.log_error e.message
    throw e
    false
  end
  
  # has this resource been destroyed
  def destroyed?
    self._removed || self.frozen?
  end
  
  private
  
  # clear the element of the cache
  def mark_destroyed!
    self.freeze
    self._removed=true 
    self.class.store.delete_resource(resource_key, id)
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
    raise Flareshow::APIAccessException if self.class.read_only && source == :client
    attributes.each do |p|
      key, value = p[0], p[1]
      self.set(key, value, source)
    end
  rescue Exception => e
    Flareshow::Util.log_error e.message
    throw e
    false
  end
  
  # keep track of dirty state on the client by maintaining a copy
  # of the original state of each intstance variable when it is provided by
  # the server
  def set(key, value, source = :client)
    raise Flareshow::APIAccessException if self.class.read_only && source == :client
    if self.class.attr_accessible && 
      !(/_removed/).match(key.to_s) &&
      !self.class.attr_accessible.include?(key.to_sym) && source == :client
      Flareshow::Util.log_error "#{self.class.name}.#{key} is not a writable field"
      raise Flareshow::APIAccessException 
    end
    # Flareshow::Util.log_info("setting #{key} : #{value}")
    @data["original_#{key}"] = value if source == :server
    @data[key.to_s]=value
  rescue Exception => e
    Flareshow::Util.log_error e.message
    throw e
    false
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