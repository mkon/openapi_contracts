require 'active_support/core_ext/module'

module OpenapiContracts
  autoload :Doc,      'openapi_contracts/doc'
  autoload :Header,   'openapi_contracts/header'
  autoload :Parser,   'openapi_contracts/parser'
  autoload :Response, 'openapi_contracts/response'
end
