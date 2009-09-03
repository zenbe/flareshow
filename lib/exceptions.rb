module Flareshow
  class ConfigurationException < Exception
    # exception thrown if the API client is not configured properly
  end

  class AuthenticationRequired < Exception
    # exception thrown if a request is made without a logged in user
  end

  class AuthenticationFailed < Exception
    # exception thrown if an auth request fails
  end
end