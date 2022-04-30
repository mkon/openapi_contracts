require 'active_support'
require 'active_support/core_ext/array'
require 'active_support/core_ext/module'

require 'json-schema'
require 'yaml'

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
