class Post < Flareshow::Base
  
  # permalink to this post
  def permalink(mobile=false)
    if mobile
      "http://#{Flareshow::Base.server.host}/#{Flareshow::Base.server.domain}/shareflow/mobile/post/#{id}"
    else
      "http://#{Flareshow::Base.server.host}/#{Flareshow::Base.server.domain}/shareflow/p/#{id}"
    end
  end
  
end