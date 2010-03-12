class Post < Flareshow::Resource
  @attr_accessible = [:content, :flow_id, :files]
  @attr_required = [:flow_id]
  
  extend Flareshow::Searchable
  
  # permalink to this post
  def permalink(mobile=false)
    if mobile
      "http://#{Flareshow::Service.server.host}/#{Flareshow::Service.server.domain}/shareflow/mobile/post/#{id}"
    else
      "http://#{Flareshow::Service.server.host}/#{Flareshow::Service.server.domain}/shareflow/p/#{id}"
    end
  end
  
  # build a new comment but don't immediately persist it
  def build_comment(attributes={})
    c = Comment.new(attributes)
    c.post_id = self.id
    c
  end
  
  # create a new comment on the post
  def create_comment(attributes={})
    c = build_comment(attributes)
    c.save
  end
  
  # build a new file object on the client but don't commit to the server immediately
  def build_file(file_path)
    self.files ||= []
    self.files += [{"part_id" => "file_#{UUID.generate}", "file_path" => file_path}]
  end
  
  # upload a file to a post
  def create_file(file_path)
    self.files = []
    self.build_file(file_path)
    self.save
    self.files = []
  end
  
  # persisted files for this post
  def files
    FileAttachment.find({:post_id => id}) || []
  end
  
  # comments for this post
  def comments
    Comment.find({:post_id => id})
  end
  
  # user for this post
  def user
    return User.current unless user_id
    user = User.get_from_cache(user_id)
    user || User.first({:id => user_id})
  end
  
  # get the flow for this post
  def flow
    return false unless flow_id
    Flow.first({:id => flow_id})
  end
  
end