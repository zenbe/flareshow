class Invitation < Flareshow::Resource
  
  @read_only=true
  
  # =================
  # = Class Methods =
  # =================
  class << self
    # invitations dont have timestamps currently
    # overriding the default
    def default_params
      {}
    end
  end

end