class FileAttachment < Flareshow::Resource
  
  @read_only=true
  
  extend Flareshow::Searchable
  
  # =================
  # = Class Methods =
  # =================
  class << self
    # file attachments has a resource key of files 
    # for querying the server
    def resource_key
      "files"
    end
  end
  
  # download the file contents
  def download
    url = self.url
    unless url.match(/http/)
      url = "http://#{Flareshow::Base.server.host}/#{Flareshow::Base.server.domain}#{url}"
    end
    Flareshow::Util.log_info("getting #{url}")
    self.class.http_get(url)
  end
  
end