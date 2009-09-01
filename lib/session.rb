class Session < Flareshow::Base
  
  attr_reader :user
  
  def self.endpoint(host, domain)
    "http://#{host}/#{domain}/shareflow/api/v2/auth.json"
  end
  
  def log_in(host, subdomain, login, password)
    self.class.post(
      self.class.endpoint(host, subdomain), 
      {:login => login, :password => password}, 
      {
        :on_success  => method(:on_login),
        :on_failure => method(:on_login_failure)
      }
    )
  end
  
  def logout
    
  end

  def logged_in?
    
  end
  
  private
  
  def on_login(response_body)
    @user = User.new(response_body["data"])
  end
  
  def on_login_failure(response_body)
    
  end
  
end