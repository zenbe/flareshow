class Flow < Flareshow::Base

  # permalink for this flow
  def permalink(mobile=false)
    if mobile
      "http://#{Flareshow::Base.server.host}/#{Flareshow::Base.server.domain}/shareflow/mobile/flows/#{id}"
    else
      "http://#{Flareshow::Base.server.host}/#{Flareshow::Base.server.domain}/shareflow/c/#{id}"
    end
  end
  
  #invite/reinvite a user to a flow by email address
  def send_invitions(email_addresses)
    self.invite = [email_addresses].flatten
    self.save
  end
  
  # uninvite an invited user from a flow by email address
  def revoke_invitations(email_addresses)
    self.uninvite = [email_addresses].flatten
    self.save
  end
  
  # remove a user from a flow
  # you must be the owner of the flow to perform
  # this action
  def remove_members(member_ids)
    self.remove_members = [email_addresses].flatten
    self.save
  end
  
  # build a new post but don't persist it immediatel
  def build_post
    post = Post.new
    post.flow_id = id
    post
  end
  
  # create a new post in this flow
  def create_post(attributes)
    p=build(post)
    p.update(attributes)
    p.save
  end
  
end