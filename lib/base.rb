module Flareshow
  
  ResourceToClassMap = {
    "flows"       => "Flow",
    "posts"       => "Post",
    "comments"    => "Comment",
    "files"       => "FileAttachment",
    "memberships" => "Membership",
    "invitations" => "Invitations"
  }
  ClassToResourceMap = ResourceToClassMap.invert
  
  
  class Base < OpenStruct
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
        dispatch(response, callbacks)
      end
      
      # query the server
      def query(params={}, callbacks={})
        raise UserRequiredException unless User.current
        response = post(api_endpoint, {"key" => User.current.auth_token, "query" => params})
        assimilate_resources(response)
        dispatch(response, callbacks)
      end
      
      # commit changes to the server
      def commit(params={}, callbacks={})
        response = post(api_endpoint, params)
        assimilate_resources(response)
        dispatch(response, callbacks)
      end
      
      # get the interesting bits out of the curl response
      def process_response(request)
        response = {:status_code => request.response_code, :headers => request.header_str, :body => JSON.parse(request.body_str)}
        Util.log_info JSON.pretty_generate(response)
        response
      end
      
      # assimilate the resources provided in the response
      def assimilate_resources(response)
        # process each resource key and generate a new object
        # or merge the object data with an existing object
        response[:body].each do |resource_pair|
          resource_key, resources = resource_pair[0], resource_pair[1]
          klass = Kernel.const_get(Flareshow::ResourceToClassMap[resource_key])
          next unless klass
          resources.each do |resource_data|
            klass.get(resource_data)
          end
        end        
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
      def get(id_or_object)
        o = if id_or_object.is_a? String
          id = id_or_object
          store[id] ||= new({"id" => id})
        elsif
          id = id_or_object["id"]
          store[id] ||= new(id_or_object)
        end
      end
      
      # list out the instances in memory
      def list
        store.each_value do |v|
          Util.log_info(v.inspect)
        end
      end
      
      # find a resource by querying the server
      def find(params)
        key = Flareshow::ClassToResourceMap[self.name]
        self.query({key => params})
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
    def initialize(data={})
      data["primary_key"] = data["id"]
      super(data)
    end
    
    # return the server id of a resource
    def id
      primary_key
    end
    
    # reload the resource from the server
    def refresh

    end
    
    # save a resource to the server
    def save

    end
    
  end
end