class Post < Flareshow::Base
  
  # permalink to this post
  def permalink(mobile=false)
    if mobile
      "http://#{Flareshow::Base.server.host}/#{Flareshow::Base.server.domain}/shareflow/mobile/post/#{id}"
    else
      "http://#{Flareshow::Base.server.host}/#{Flareshow::Base.server.domain}/shareflow/p/#{id}"
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
  
  # upload a file to a post
  def add_file(file_path)
    f = FileAttachment.new
    f.file_path=file_path
    f.save
  end
end