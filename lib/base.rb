module Flareshow
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
        "http://#{Flareshow::Base.server.host}/#{Flareshow::Base.server.domain}/shareflow/api/v2/auth.json"
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
      def post(url, params, callbacks)
        raise ConfigurationException unless server_defined?
        request = Curl::Easy.new(url) do |curl|
          curl.headers = {
            'Accept'        => 'application/json',
            'Content-Type'  => 'application/json',
            'User-Agent'    => 'Ruby Flareshow 0.1'
          }
        end
        request.http_post(params.to_json)
        dispatch(response(request), callbacks)
      end
      
      # authenticate with the server
      def authenticate(params, callback)
        post(auth_endpoint, params, callback)
      end
      
      # query the server
      def query(params, callback)
        post(api_endpoint, params, callback)
      end
      
      # commit changes to the server
      def commit(params, callback)
        post(api_endpoint, params, callback)
      end
      
      # get the interesting bits out of the curl response
      def response(request)
        response = {:status_code => request.response_code, :headers => request.header_str, :body => JSON.parse(request.body_str)}
        Util.log_info JSON.pretty_generate(response)
        response
      end
      
      # dispatch a request to the appropriate callback
      def dispatch(response, callbacks)
        case response[:status_code]
        when 200...201
          callbacks[:on_success].call(response[:body])
        else
          callbacks[:on_failure].call(response[:body])
        end
      end
      
      # find a resource by querying the server
      def find

      end

      # create a resource local and sync it to the server
      def create

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