class Flow < Flareshow::Resource
  
  @attr_accessible = [:name, :remove_members, :uninvite, :invite]
  @attr_required = [:name]
  
  # =================
  # = Class Methods =
  # =================
  class << self
    # find a flow by name
    def find_by_name(name)
      self.first({:name => name})
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
    self.remove_members = [member_ids].flatten
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
  
  # posts for this flow...only returns the first 100 (API max)
  # to load all posts you can interact with the Service class directly
  # to loop through in batches of 100 using the offset parameter or 
  # create a flow object and override this method with the looping logic
  def posts
    Post.find(:flow_id => id)
  end
  
  # list the invitations to this flow
  def list_invitations
    Invitation.find(:flow_id => id)
  end
  
  # list all users on the flow currently
  def list_users
    response = Flareshow::Service.query({:flows=>{:id => self.id, :limit => 1, :include=>['users']}})
    (Flareshow::CacheManager.assimilate_resources(response["resources"]) || {})["users"]
  end
  
end