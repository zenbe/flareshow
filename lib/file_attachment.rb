class FileAttachment < Flareshow::Base
  
  # =================
  # = Class Methods =
  # =================
  class << self
    # file attachments has a resource key of files 
    # for querying the server
    def resource_key
      "files"
    end
  end
  
end