# provides an interface to the shareflow api
class Flareshow::Service
  
  # =================
  # = Class Methods =
  # =================
  class << self
    attr_accessor :server
    
    # setup the service to use a particular host and domain
    def configure(subdomain, host='biz.zenbe.com')
      self.server=Server.new(host, domain)
    end
    
    # return the authentication endpoint for a given host and domain
    def auth_endpoint
      "http://#{server.host}/#{server.domain}/shareflow/api/v2/auth.json"
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
          'User-Agent'    => 'flareshow 0.1'
        }
        curl.multipart_form_post=true
      end
      request.http_post(*params)
      process_response(request)
    end
    
    # do a get request
    def http_get(url)
      request = Curl::Easy.new(url + "?key=#{User.current.get("auth_token")}") do |curl|
        curl.headers = {
          'User-Agent'    => 'flareshow 0.1'
        }
      end
      request.perform()
      process_response(request)
    end
    
    # get the interesting bits out of the curl response
    def process_response(request)
      response = {:status_code => request.response_code, :headers => request.header_str, :body => request.body_str}
      if request.content_type == "application/json"
        response[:resources] = JSON.parse(response[:body])
        Util.log_info(reponse[:status_code])
      end
      response
    end
    
    # authenticate with the server using an http post
    def authenticate(params={})
      params = [
        Curl::PostField.content("login", params[:login]),
        Curl::PostField.content("password", params[:password])
      ]
      post(auth_endpoint, params)
    end
    
    # query the server with an http post of the query params
    def query(params={})
      raise UserRequiredException unless User.current

      # add the json request parts
      params = [
        Curl::PostField.content("key", User.current.get("auth_token"), 'application/json'),
        Curl::PostField.content("query", params.to_json, 'application/json')
      ]
      
      post(api_endpoint, params)
    end
    
    # commit changes to the server with an http post
    def commit(params={}, files=[])
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
        Curl::PostField.content("key", User.current.get("auth_token"), 'application/json'),
        Curl::PostField.content("data", params.to_json, 'application/json')
      ]
      
      post(api_endpoint, curl_params)
    end
    
  end
  
end