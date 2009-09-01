class Flow < Flareshow::Base

  # permalink for this flow
  def permalink(mobile=false)
    if mobile
      "http://#{Flareshow::Base.server.host}/#{Flareshow::Base.server.domain}/shareflow/mobile/flows/#{id}"
    else
      "http://#{Flareshow::Base.server.host}/#{Flareshow::Base.server.domain}/shareflow/c/#{id}"
    end
  end
  
  def invite
    
  end
  
  def uninvite
    
  end
  
  def remove_member
    
  end

end