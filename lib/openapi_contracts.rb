require 'active_support'
require 'active_support/core_ext/array'
require 'active_support/core_ext/module'
require 'active_support/core_ext/string'

require 'json_schemer'
require 'yaml'

module OpenapiContracts
  autoload :Doc,      'openapi_contracts/doc'
  autoload :Matchers, 'openapi_contracts/matchers'
end

if defined?(RSpec)
  RSpec.configure do |config|
    config.include OpenapiContracts::Matchers
  end
end
