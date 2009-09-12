# provides an interface to the shareflow api
class Flareshow::Service
  
  # =================
  # = Class Methods =
  # =================
  class << self
    attr_accessor :server, :debug_output, :key
    
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
    def post(uri, params, files=[])
      raise Flareshow::ConfigurationException unless server_defined?
      # create the request object
      req = Net::HTTP::Post.new(uri.path)
      # set request headers
      req.add_field "Accept", "application/json"
      req.add_field "User-Agent", "ruby flareshow"
      req.add_field "Accept-Encoding", "compress, gzip"

      # just json
      if !files || files.empty?
        req.add_field "Content-type", "application/json; charset=UTF-8"
        # set the postbody
        req.body = params.to_json
      # handle file params
      else
        params = params.map{|p| 
          val = p[1].is_a?(String) ? p[1] : p[1].to_json
          Param.new(p[0], val, "application/json")
        }
        files.each do |f|
          params << FileParam.new(f["part_id"], f["file_path"], File.read(f["file_path"]))
        end
        body, header = *MultipartPost.prepare_query(params)
        req.add_field "Content-type", header["Content-type"]
        req.body = body
      end
      
      # make the request
      http = Net::HTTP.new(uri.host, uri.port)
      http.set_debug_output DEFAULT_LOGGER if debug_output
      response = http.start {|h| h.request(req)}
      
      # normalize the response
      response = process_response(response)
      log_response(response)
      response
    end
    
    # do a get request
    def http_get(uri)
      uri = URI.parse(uri) unless uri.is_a? URI
      req = Net::HTTP::Get.new(uri.path + "?key=#{@key}")
      req.add_field "User-Agent", "ruby flareshow"
      http = Net::HTTP.new(uri.host, uri.port)
      http.set_debug_output DEFAULT_LOGGER if debug_output
      response = http.start{|h|http.request(req)}
      response = process_response(response)
      Flareshow::Util.log_error("resource not found") if response["status_code"] == 404
      response
    end
    
    # log the response
    def log_response(response)
      # log a service exception
      case response["status_code"]
        when 400
          log_service_error(response)
        when 500
          log_service_error(response)
        when 403
          log_service_error(response)
      end
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
      params, files = *files_from_params(params) if params["posts"]
      params = {"key" => @key, "data" => params}
      post(api_endpoint, params, files)
    end
    
    # get the files out of the params
    def files_from_params(params)
      files = []
      # add any file parts passed in and assign a part id to the 
      params["posts"] = (params["posts"]).map do |f|
        if f["files"]
          f["files"] = (f["files"]).map do |ff|
            # we only want to send up new files from the client so we'll strip out any existing
            # files in the params that came down from the server
            val = nil
            if ff["part_id"]
              val = {"part_id" => ff["part_id"], "file_path" => ff["file_path"]} 
              files << val
            end
            val
          end.compact
        end
        f
      end
      [params, files]
    end
    
    # get the interesting bits out of the curl response
    def process_response(response)
      # read the response headers
      headers = {}; response.each_header{|k,v| headers[k] = v}
      # build a response object
      response_obj = {"status_code" => response.code.to_i, "headers" => headers, "body" => response.plain_body}
      
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