module OpenapiContracts
  module Validators
    autoload :Base,       'openapi_contracts/validators/base'
    autoload :Body,       'openapi_contracts/validators/body'
    autoload :Documented, 'openapi_contracts/validators/documented'
    autoload :Headers,    'openapi_contracts/validators/headers'
    autoload :HttpStatus, 'openapi_contracts/validators/http_status'
    autoload :Request, 'openapi_contracts/validators/request'

    # Defines order of matching
    ALL = [
      Documented,
      HttpStatus,
      Request,
      Body,
      Headers
    ].freeze
  end
end
