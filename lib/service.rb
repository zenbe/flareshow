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
      @auth_endpoint = @api_endpoint = nil
    end
    
    # return the authentication endpoint for a given host and domain
    def auth_endpoint
      @auth_endpoint ||= URI.parse("http://#{server.host}/#{server.domain}/shareflow/api/v2/auth.json")
    end
    
    # return the api endpoint for a given host and domain
    def api_endpoint
      @api_endpoint ||= URI.parse("http://#{server.host}/#{server.domain}/shareflow/api/v2.json")
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
    def post(uri, params)
      raise Flareshow::ConfigurationException unless server_defined?
      # create the request object
      req = Net::HTTP::Post.new(uri.path)
      # set request headers
      req.add_field "Accept", "application/json"
      req.add_field "User-Agent", "ruby flareshow"
      req.add_field "Accept-Encoding", "compress, gzip"
      req.add_field "Content-Type", "application/json"
      
      # set the postbody
      req.body = params.to_json
      
      # make the request
      response = Net::HTTP.new(uri.host, uri.port).start {|http| 
        http.request(req)
      }
      
      # normalize the response
      response = process_response(response)

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
    
    # make a multipart post
    def multipart_post
      
    end
    
    # do a get request
    def http_get(uri)
      req = Net::HTTP::Get.new(uri.path)
      req.add_field "User-Agent", "ruby flareshow"
      response = Net::HTTP.new(uri.host, uri.port).start{|http|
        http.request(req)
      }
      response = process_response(response)
      Flareshow::Util.log_error("resource not found") if response["status_code"] == 404
      response
    end
    
    # authenticate with the server using an http post
    def authenticate(login, password)
      params = {:login => login, :password => password}
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
      Flareshow::Util.log_error e.backtrace.join("\n")
    end
    
    # query the server with an http post of the query params
    def query(params={})
      raise Flareshow::AuthenticationRequired unless @key
      params = {"key" => @key, "query" => params}
      post(api_endpoint, params)
    end
    
    # commit changes to the server with an http post
    def commit(params={}, files=[])
      raise Flareshow::AuthenticationRequired unless @key

      # TODO: Fix this
      # curl_params = []
      # has_files = false
      # if params["posts"]
      #   # add any file parts passed in and assign a part id to the 
      #   params["posts"] = (params["posts"]).map do |f|
      #     if f["files"]
      #       f["files"] = (f["files"]).each do |ff|
      #         has_files = true
      #         curl_params.push(Curl::PostField.file(ff["part_id"], ff["file_path"]))
      #       end
      #     end
      #     f
      #   end
      # end
      # 
      # params["files"] = []
      
      # add the json request parts
      # curl_params += [
      #   Curl::PostField.content("key", @key, 'application/json'),
      #   Curl::PostField.content("data", params.to_json, 'application/json')
      # ]
      
      params = {"key" => @key, "data" => params}
      post(api_endpoint, params)
    end
    
    # get the interesting bits out of the curl response
    def process_response(response)
      # read the response headers
      headers = {}; response.each_header{|k,v| headers[k] = v}
      # build a response object
      response_obj = {"status_code" => response.code.to_i, "headers" => headers, "body" => response.body}
      
      # automatically handle json response
      if (/json/i).match(response.content_type)
        response_obj["resources"] = JSON.parse(response_obj["body"])
      end
      
      # log the response
      Flareshow::Util.log_info(response_obj["status_code"])
      Flareshow::Util.log_info(response_obj["body"])
      response_obj
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
    
    # clear the authenticated session
    def logout
      @key = nil
    end
    
    # are we authenticated
    def authenticated?
      !!@key
    end
    
  end
  
end