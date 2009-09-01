ROOT = File.dirname(__FILE__) unless defined? ROOT
$:.unshift(File.join(ROOT, "lib"))

require 'json'
require 'curb'
require 'ostruct'
require 'logger'

require 'base'

# logging
DEFAULT_LOGGER = Logger.new(STDOUT) unless defined?(DEFAULT_LOGGER)

Dir.glob(File.join(ROOT, "**", "*.rb")).each{|lib| require lib}

# initial setup
Flareshow::Base.server = Server.new("zenbedevelopment.com", "webco.zenbedevelopment.com")