class Flow < Flareshow::Resource
  
  @attr_accessible = [:name]
  @attr_required = [:name]
  
  # =================
  # = Class Methods =
  # =================
  class << self
    # find a flow by name
    def find_by_name(name)
      self.find({:name => name})
    end
  end
  
  # permalink for this flow
  def permalink(mobile=false)
    if mobile
      "http://#{Flareshow::Service.server.host}/#{Flareshow::Service.server.domain}/shareflow/mobile/flows/#{id}"
    else
      "http://#{Flareshow::Service.server.host}/#{Flareshow::Service.server.domain}/shareflow/c/#{id}"
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
  def build_post(attributes)
    post = Post.new
    post.update(attributes)
    post.flow_id = id
    post
  end
  
  # create a new post in this flow
  def create_post(attributes)
    p=build_post(attributes)
    p.save
  end
  
end