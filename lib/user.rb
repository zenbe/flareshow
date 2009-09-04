class User < Flareshow::Resource
  
  @read_only=true
  
  # =================
  # = Class Methods =
  # =================
  class << self
    
    # return the current authenticated user
    def current
      @current
    end
    
    # authenticate user credentials
    def log_in(login, password)
      response = Flareshow::Service.authenticate(login, password)
      user_data = response["resources"]["data"]
      Flareshow::CacheManager.assimilate_resources({resource_key => [user_data]})
      @current = User.get_from_cache(user_data["id"])
    end
    
    # ==================
    # = Authentication =
    # ==================
    def logout
      Flareshow::Service.logout
      @current = nil
    end
    
  end
  
  # ====================
  # = Instance Methods =
  # ====================
  
  # ================
  # = Associations =
  # ================
  def flows
    Flow.find({"user_id" => ["in", id]})
  end
  
  def posts
    Post.find({"user_id" => ["in", id]})
  end
  
  def comments
    Comment.find({"user_id" => ["in", id]})
  end
  
  def files
    File.find({"user_id" => ["in", id]})
  end
  
  def logged_in?
    @current
  end
  
end