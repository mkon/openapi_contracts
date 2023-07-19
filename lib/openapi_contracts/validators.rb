module OpenapiContracts
  module Validators
    autoload :Base,             'openapi_contracts/validators/base'
    autoload :Documented,       'openapi_contracts/validators/documented'
    autoload :Headers,          'openapi_contracts/validators/headers'
    autoload :HttpStatus,       'openapi_contracts/validators/http_status'
    autoload :RequestBody,      'openapi_contracts/validators/request_body'
    autoload :ResponseBody,     'openapi_contracts/validators/response_body'
    autoload :SchemaValidation, 'openapi_contracts/validators/schema_validation'

    # Defines order of matching
    ALL = [
      Documented,
      HttpStatus,
      RequestBody,
      ResponseBody,
      Headers
    ].freeze
  end
end
