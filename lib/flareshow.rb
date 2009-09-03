ROOT = File.dirname(__FILE__) unless defined? ROOT

# gems
require 'rubygems' #TODO fix
require 'json'
require 'curb'
require 'facets'
require 'facets/dictionary'
require 'uuid'

# std lib
require 'ostruct'
require 'logger'

# app
require 'base'

# logging
DEFAULT_LOGGER = Logger.new(STDOUT) unless defined?(DEFAULT_LOGGER)

Dir.glob(File.join(ROOT, "*.rb")).each{|lib| require lib}

module Flareshow
  
  # default parameters that are included with query
  # requests unless they are explicitly overridden
  DEFAULT_PARAMS = {:order => "created_at desc"} unless defined? DEFAULT_PARAMS
  
  # mappings to allow easy conversion from the
  # response keys the server sends back in JSUP
  # messages
  ResourceToClassMap = {
    "flows"       => "Flow",
    "posts"       => "Post",
    "comments"    => "Comment",
    "files"       => "FileAttachment",
    "memberships" => "Membership",
    "invitations" => "Invitation",
    "users"       => "User"
  } unless defined? ResourceToClassMap
  ClassToResourceMap = ResourceToClassMap.invert unless defined? ClassToResourceMap
  
end