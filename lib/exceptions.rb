module Flareshow
  
  class MissingRequiredField < Exception
    def message
      "you attempted to save an object without providing all of the required fields"
    end
  end
  
  class APIAccessException < Exception
    def message 
      "you've attempted to change an object in a way not permitted by the API"
    end
  end
  
  class ConfigurationException < Exception
    def message
      "the shareflow service connection has not been configured properly"
    end
  end

  class AuthenticationRequired < Exception
    def message
      "this action requires authentication"
    end
  end

  class AuthenticationFailed < Exception
    def message
      "authentication failed"
    end
  end
end