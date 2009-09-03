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
