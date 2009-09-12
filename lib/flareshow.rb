ROOT = File.dirname(__FILE__) unless defined? ROOT

# gems
require 'rubygems' #TODO fix
require 'json'
require 'facets'
require 'facets/dictionary'
require 'uuid'
require 'mime/types'
require 'cgi'

# std lib
require 'net/http'
require 'net/https'
require 'ostruct'
require 'yaml'
require 'logger'
require 'ruby-debug'

# Application Constants and configuration
module Flareshow
  
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
DEFAULT_LOGGER.level = Logger::ERROR
Dir.glob(File.join(ROOT, "*.rb")).each{|lib| require lib}

# check for presence of config file
config_file_path = File.expand_path("~/.flareshowrc")
if File.exists?(config_file_path) && !Flareshow::Service.authenticated?
  data = YAML.load_file(config_file_path)
  Flareshow::Service.debug_output=true if data["debug_http"]
  host = data["host"] || "biz.zenbe.com"
  subdomain = data["subdomain"]
  DEFAULT_LOGGER.level = data["log_level"].to_i if data["log_level"]
  Flareshow::Service.configure(subdomain, host)
  if data["login"] && data["password"]
    User.log_in(data["login"], data["password"])
  end
end