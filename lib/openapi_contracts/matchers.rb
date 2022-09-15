module OpenapiContracts
  module Matchers
    autoload :MatchOpenapiDoc, 'openapi_contracts/matchers/match_openapi_doc'

    def match_openapi_doc(doc, options = {})
      MatchOpenapiDoc.new(doc, options)
    end
  end
end
