class User < Flareshow::Base

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
      authenticate({:login => login, :password => password}, 
        {
          :on_success  => method(:on_authentication_success),
          :on_failure  => method(:on_authentication_failure)
        }
      )
    end
    
    private 
    
    # =============
    # = Callbacks =
    # =============
    # login success callback
    def on_authentication_success(response_body)
      @current = User.get(response_body["data"])
    end

    # login failed callback
    def on_authentication_failure(response_body)
      Util.log_error("failed to login: #{response_body}")
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
  
  # ==================
  # = Authentication =
  # ==================
  def logout
    
  end

  def logged_in?
    auth_token
  end
  
end