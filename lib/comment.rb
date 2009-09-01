class Comment < Flareshow::Base
  
  # permalink to this comment
  def permalink(mobile=false)
    if mobile
      "http://#{Flareshow::Base.server.host}/#{Flareshow::Base.server.domain}/shareflow/mobile/post/#{reply_to}"
    else
      "http://#{Flareshow::Base.server.host}/#{Flareshow::Base.server.domain}/shareflow/p/#{reply_to}?comment_id#{id}"
    end
  end
  
end