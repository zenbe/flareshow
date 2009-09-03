class Flareshow::Resource
  
  class << self
    # find an existing instance of this object in the client or create a new one
    def get(id_or_object, source = :client)
      o = if id_or_object.is_a?(String) || id_or_object.is_a?(Integer)
        id = id_or_object.to_s
        store[id] ||= new({"id" => id}, source)
      elsif
        id = id_or_object["id"]
        store[id] ||= new(id_or_object, source)
      end
    end
  
    # list out the instances in memory
    def list
      store.each_value do |v|
        Util.log_info(v.inspect)
      end
    end
  
    # get all the resources of this type from the server
    def all
      key = Flareshow::ClassToResourceMap[self.name]
      params = DEFAULT_PARAMS
      self.query({key => params})
    end
  
    # find a resource by querying the server
    def find(params)
      key = Flareshow::ClassToResourceMap[self.name]
      params = DEFAULT_PARAMS.merge(params)
      (self.query({key => params}) || {})[key]
    end

    # return the first resource in the client store
    # or go to the server and fetch one item
    def first
      return store.first if store.size > 0
      find({:limit => 1})
      return store.first
    end
  

    # create a resource local and sync it to the server
    def create(params)
      new(params).save
    end
  
    def store
      @objects ||= Dictionary.new
    end
  end
  
  # constructor
  # build a new Flareshow::Base resource
  def initialize(data={}, source = :client)
    @data = {}
    data["id"] = UUID.generate.upcase if source == :client
    update(data, source)
  end

  # ==============================
  # = Server Persistence Actions =
  # ==============================
  
  # reload the resource from the server
  def refresh(callbacks={})
    key = Flareshow::ClassToResourceMap[self.class.name]
    results = self.class.query({key => {"id" => id}}, callbacks)
    mark_destroyed! if results.empty?
    self
  end
  
  # save a resource to the server
  def save(callbacks={})
    key = Flareshow::ClassToResourceMap[self.class.name]
    self.class.commit({key => [(self.changes || {}).merge({"id" => id})] }, callbacks)
    self
  end
  
  # destroy the resource on the server
  def destroy(callbacks={})
    key = Flareshow::ClassToResourceMap[self.class.name]
    self.class.commit({key => [{"id" => id, "_removed" => true}]}, callbacks)
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
    # Util.log_info("setting #{key} : #{value}")
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