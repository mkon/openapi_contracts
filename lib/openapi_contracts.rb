require 'active_support'
require 'active_support/core_ext/array'
require 'active_support/core_ext/class'
require 'active_support/core_ext/module'
require 'active_support/core_ext/string'

require 'json_schemer'
require 'yaml'

module OpenapiContracts
  autoload :Doc,       'openapi_contracts/doc'
  autoload :Helper,    'openapi_contracts/helper'
  autoload :Matchers,  'openapi_contracts/matchers'
  autoload :Validator, 'openapi_contracts/validator'

  # Defines order of matching
  MATCHERS = [
    Matchers::Documented,
    Matchers::HttpStatus,
    Matchers::Body,
    Matchers::Headers
  ].freeze

  Env = Struct.new(:spec, :response, :expected_status)
end

require 'openapi_contracts/rspec' if defined?(RSpec)
