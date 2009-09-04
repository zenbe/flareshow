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
    Post.first(:id => post_id)
  end
  
  # user for this post
  def user
    return User.current unless user_id
    User.first({:id => user_id})
  end
  
end