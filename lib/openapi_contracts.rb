require 'active_support'
require 'active_support/core_ext/array'
require 'active_support/core_ext/class'
require 'active_support/core_ext/module'
require 'active_support/core_ext/string'

require 'json_schemer'
require 'yaml'

module OpenapiContracts
  autoload :Doc,        'openapi_contracts/doc'
  autoload :Helper,     'openapi_contracts/helper'
  autoload :Match,      'openapi_contracts/match'
  autoload :Validators, 'openapi_contracts/validators'

  Env = Struct.new(:spec, :response, :expected_status)

  module_function

  def match(doc, response, options = {})
    Match.new(doc, response, options)
  end
end

require 'openapi_contracts/rspec' if defined?(RSpec)
