require 'active_support/isolated_execution_state' # required by array somehow
require 'active_support/core_ext/array'
require 'active_support/core_ext/module'
require 'json-schema'

module OpenapiContracts
  autoload :Doc,      'openapi_contracts/doc'
  autoload :Header,   'openapi_contracts/header'
  autoload :Matchers, 'openapi_contracts/matchers'
  autoload :Parser,   'openapi_contracts/parser'
  autoload :Response, 'openapi_contracts/response'
end

RSpec.configure do |config|
  config.include OpenapiContracts::Matchers
end
