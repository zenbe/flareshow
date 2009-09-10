# provides an interface to the shareflow api
class Flareshow::Service
  
  # =================
  # = Class Methods =
  # =================
  class << self
    attr_accessor :server
    
    # setup the service to use a particular host and domain
    def configure(subdomain=nil, host='api.zenbe.com')
      raise Flareshow::ConfigurationException unless subdomain
      self.server=Server.new(host, subdomain)
    end
    
    # return the authentication endpoint for a given host and domain
    def auth_endpoint
      "http://#{server.host}/#{server.domain}/shareflow/api/v2/auth.json"
    end
    
    # return the api endpoint for a given host and domain
    def api_endpoint
      "http://#{server.host}/#{server.domain}/shareflow/api/v2.json"
    end
    
    # has the server been configured?
    def server_defined?
      !!server
    end
    
    # make a post request to an endpoint
    # returns a hash of
    #  - status code
    #  - headers
    #  - body
    def post(url, params)
      raise Flareshow::ConfigurationException unless server_defined?
      request = Curl::Easy.new(url) do |curl|
        curl.headers = {
          'Accept'        => 'application/json',
          'User-Agent'    => 'flareshow 0.1'
        }
        curl.multipart_form_post=true
      end
      request.http_post(*params)
      response = process_response(request)

      # log a service exception
      case response["status_code"]
        when 400
          log_service_error(response)
        when 500
          log_service_error(response)
        when 403
          log_service_error(response)
      end
        
      response
    end
    
    # do a get request
    def http_get(url)
      request = Curl::Easy.new(url + "?key=#{@key}") do |curl|
        curl.headers = {
          'User-Agent'    => 'flareshow 0.1'
        }
      end
      request.perform()
      response = process_response(request)
      
      Flareshow::Util.log_error("resource not found") if response["status_code"] == 404
      
      response
    end
    
    # get the interesting bits out of the curl response
    def process_response(request)
      response = {"status_code" => request.response_code, "headers" => request.header_str, "body" => request.body_str}
      if (/json/i).match(request.content_type)
        response["resources"] = JSON.parse(response["body"])
      end
      Flareshow::Util.log_info(response["status_code"])
      Flareshow::Util.log_info(response["body"])
      response
    end
    
    # log a service error
    def log_service_error(response)
      if response["resources"]
        Flareshow::Util.log_error(response["resources"]["message"])
        Flareshow::Util.log_error(response["resources"]["details"]) 
      else
        Flareshow::Util.log_error(response["body"])
      end
    end
    
    # authenticate with the server using an http post
    def authenticate(login, password)
      params = [
        Curl::PostField.content("login", login),
        Curl::PostField.content("password", password)
      ]
      response = post(auth_endpoint, params)
      # store the auth token returned from the authentication request
      if response["status_code"] == 200
        @key = response["resources"]["data"]["auth_token"]
        response
      else
        raise Flareshow::AuthenticationFailed
      end
    rescue Exception => e
      Flareshow::Util.log_error e.message
    end
    
    # clear the authenticated session
    def logout
      @key = nil
    end
    
    # are we authenticated
    def authenticated?
      !!@key
    end
    
    # query the server with an http post of the query params
    def query(params={})
      raise Flareshow::AuthenticationRequired unless @key

      # add the json request parts
      params = [
        Curl::PostField.content("key", @key, 'application/json'),
        Curl::PostField.content("query", params.to_json, 'application/json')
      ]
      
      post(api_endpoint, params)
    end
    
    # commit changes to the server with an http post
    def commit(params={}, files=[])
      raise Flareshow::AuthenticationRequired unless @key

      curl_params = []
      has_files = false
      if params["posts"]
        # add any file parts passed in and assign a part id to the 
        params["posts"] = (params["posts"]).map do |f|
          if f["files"]
            f["files"] = (f["files"]).each do |ff|
              has_files = true
              curl_params.push(Curl::PostField.file(ff["part_id"], ff["file_path"]))
            end
          end
          f
        end
      end
      
      params["files"] = []
      
      # add the json request parts
      curl_params += [
        Curl::PostField.content("key", @key, 'application/json'),
        Curl::PostField.content("data", params.to_json, 'application/json')
      ]
      
      post(api_endpoint, curl_params)
    end
    
  end
  
end