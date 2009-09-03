class ConfigurationException < Exception
  # exception thrown if the API client is not configured properly
end


class UserRequiredException < Exception
  # exception thrown if a request is made without a logged in user
end