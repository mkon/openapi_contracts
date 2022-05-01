require 'active_support'
require 'active_support/core_ext/array'
require 'active_support/core_ext/module'

require 'json-schema'
require 'yaml'

module OpenapiContracts
  autoload :Doc,      'openapi_contracts/doc'
  autoload :Matchers, 'openapi_contracts/matchers'
end

RSpec.configure do |config|
  config.include OpenapiContracts::Matchers
end
