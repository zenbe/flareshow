class Comment < Flareshow::Resource
  
  extend Flareshow::Searchable
  
  # permalink to this comment
  def permalink(mobile=false)
    if mobile
      "http://#{Flareshow::Service.server.host}/#{Flareshow::Service.server.domain}/shareflow/mobile/post/#{reply_to}"
    else
      "http://#{Flareshow::Service.server.host}/#{Flareshow::Service.server.domain}/shareflow/p/#{reply_to}?comment_id#{id}"
    end
  end
  
end