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
      url = "http://#{Flareshow::Service.server.host}/#{Flareshow::Service.server.domain}#{url}"
    end
    Flareshow::Util.log_info("getting #{url}")
    Flareshow::Service.http_get(url)
  end
  
  # post for this file
  def post
    return false unless post_id
    post = Post.get_from_cache(post_id)
    post ||= Comment.get_from_cache(post_id)
    post ||= Post.find({:id => post_id})
    post ||= Comment.find({:id => post_id})
  end
  
  # user for this post
  def user
    return User.current unless user_id
    user = User.get_from_cache(user_id)
    user || User.first({:id => user_id})
  end
  
end