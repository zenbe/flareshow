module Flareshow
  
  # default parameters that are included with query
  # requests unless they are explicitly overridden
  DEFAULT_PARAMS = {:order => "created_at desc"} unless defined? DEFAULT_PARAMS
  
  # mappings to allow easy conversion from the
  # response keys the server sends back in JSUP
  # messages
  ResourceToClassMap = {
    "flows"       => "Flow",
    "posts"       => "Post",
    "comments"    => "Comment",
    "files"       => "FileAttachment",
    "memberships" => "Membership",
    "invitations" => "Invitation",
    "users"       => "User"
  } unless defined? ResourceToClassMap
  ClassToResourceMap = ResourceToClassMap.invert unless defined? ClassToResourceMap
  
  # Flareshow objects are subclasses of OpenStruct
  # allowing for a flexible definition of properties
  # as JSON returned from server requests
  class Base
    # =================
    # = Class Methods =
    # =================
    class << self
      attr_accessor :server
      
      # return the authentication endpoint for a given host and domain
      def auth_endpoint
        "http://#{Flareshow::Base.server.host}/#{Flareshow::Base.server.domain}/shareflow/api/v2/auth.json"
      end
      
      # return the api endpoint for a given host and domain
      def api_endpoint
        "http://#{Flareshow::Base.server.host}/#{Flareshow::Base.server.domain}/shareflow/api/v2.json"
      end
      
      # has the server been configured?
      def server_defined?
        !!Flareshow::Base.server
      end
      
      # make a post request to an endpoint
      # returns a hash of
      #  - status code
      #  - headers
      #  - body
      def post(url, params)
        raise ConfigurationException unless server_defined?
        request = Curl::Easy.new(url) do |curl|
          curl.headers = {
            'Accept'        => 'application/json',
            'Content-Type'  => 'application/json',
            'User-Agent'    => 'Ruby Flareshow 0.1'
          }
        end
        request.http_post(params.to_json)
        process_response(request)
      end
      
      # authenticate with the server
      def authenticate(params={}, callbacks={})
        response = post(auth_endpoint, params)
        handle_response(response, callbacks)
      end
      
      # query the server
      def query(params={}, callbacks={})
        raise UserRequiredException unless User.current
        response = post(api_endpoint, {"key" => User.current.get("auth_token"), "query" => params})
        results = assimilate_resources(response) if response[:status_code] == 200
        handle_response(response,callbacks,results)
      end
      
      # commit changes to the server
      def commit(params={}, callbacks={})
        response = post(api_endpoint, {"key" => User.current.get("auth_token"), "data" => params})
        results = assimilate_resources(response) if response[:status_code] == 200
        handle_response(response,callbacks,results)
      end
      
      # return the results directly or invoke callbacks if provided
      def handle_response(response, callbacks={}, results=nil)
        if callbacks.empty?
          results
        else
          dispatch(response, callbacks)
          true
        end
      end
      
      # get the interesting bits out of the curl response
      def process_response(request)
        response = {:status_code => request.response_code, :headers => request.header_str, :body => JSON.parse(request.body_str)}
        Util.log_info JSON.pretty_generate(response)
        response
      end
      
      # assimilate the resources provided in the response
      def assimilate_resources(response)
        results = {}
        # process each resource key and generate a new object
        # or merge the object data with an existing object
        response[:body].each do |resource_pair|
          resource_key, resources = resource_pair[0], resource_pair[1]
          klass = Kernel.const_get(Flareshow::ResourceToClassMap[resource_key])
          next unless klass
          resources.each do |resource_data|
            item = klass.get(resource_data["id"], :server)
            item.update(resource_data, :server)
            results[resource_key] ||= []
            results[resource_key].push(item)
          end
        end
        results
      end
      
      # dispatch a request to the appropriate callback
      def dispatch(response, callbacks={})
        case response[:status_code]
        when 200...201
          callbacks[:on_success].call(response[:body]) if callbacks[:on_success]
        else
          callbacks[:on_failure].call(response[:body]) if callbacks[:on_failure]
        end
      end
      
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
    
    # ====================
    # = Instance Methods =
    # ====================
    
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
      @data[key]=value
    end
    
    # get a data value
    def get(key)
      @data[key]
    end
    
    # all the state that has been modified on the client
    def changes
      attributes = @data.inject({}) do |memo, pair|
        key, value = *pair
        if @data[key] != @data["original_#{key}"] && !key.match(/original/)
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
end