ROOT = File.dirname(__FILE__) unless defined? ROOT

# gems
require 'rubygems' #TODO fix
require 'json'
require 'curb'
require 'facets'
require 'facets/dictionary'
require 'uuid'
require 'ruby-debug'

# std lib
require 'ostruct'
require 'yaml'
require 'logger'

# Application Constants and configuration
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

# app
require File.join(ROOT, 'service')
require File.join(ROOT, 'resource')
require File.join(ROOT, 'cache')
require File.join(ROOT, 'searchable')

# logging
DEFAULT_LOGGER = Logger.new(STDOUT) unless defined?(DEFAULT_LOGGER)

Dir.glob(File.join(ROOT, "*.rb")).each{|lib| require lib}

# check for presence of config file
config_file_path = File.expand_path("~/.flareshowrc")
if File.exists?(config_file_path)
  data = YAML.load_file(config_file_path)
  host = data["host"] || "biz.zenbe.com"
  subdomain = data["subdomain"]
  Flareshow::Service.configure(subdomain, host)
  
  if data["login"] && data["password"]
    User.log_in(data["login"], data["password"])
  end
end