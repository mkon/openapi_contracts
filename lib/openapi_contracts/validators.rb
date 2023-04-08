module OpenapiContracts
  module Validators
    autoload :Base,       'openapi_contracts/validators/base'
    autoload :Body,       'openapi_contracts/validators/body'
    autoload :Documented, 'openapi_contracts/validators/documented'
    autoload :Headers,    'openapi_contracts/validators/headers'
    autoload :HttpStatus, 'openapi_contracts/validators/http_status'

    # Defines order of matching
    ALL = [
      Documented,
      HttpStatus,
      Body,
      Headers
    ].freeze
  end
end
