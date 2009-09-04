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
  
  # post for this file
  def post
    return false unless post_id
    Post.find({:id => post_id})
  end
  
  # get the user for this file
  def user
    p = post && post.first
    p.user && p.user.first
  end
  
end