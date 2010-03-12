class Comment < Flareshow::Resource
  
  @attr_accessible = [:content, :post_id]
  @attr_required = [:post_id, :content]
  
  extend Flareshow::Searchable
  
  # permalink to this comment
  def permalink(mobile=false)
    if mobile
      "http://#{Flareshow::Service.server.host}/#{Flareshow::Service.server.domain}/shareflow/mobile/post/#{reply_to}"
    else
      "http://#{Flareshow::Service.server.host}/#{Flareshow::Service.server.domain}/shareflow/p/#{reply_to}?comment_id#{id}"
    end
  end
  
  # get the post for this comment
  def post
    post = Post.get_from_cache(reply_to)
    post || Post.first(:id => reply_to)
  end
  
  # user for this post
  def user
    return User.current unless user_id
    user = User.get_from_cache(user_id)
    user || User.first({:id => user_id})
  end
  
  # persisted files for this post
  def files
    cached = FileAttachment.list_cache
    files = cached.select{|f|f.post_id == id}
  end
  
  def content
    Nokogiri::HTML::Document.new.fragment(get("content")).to_s
  end
  
end