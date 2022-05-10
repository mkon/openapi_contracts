module OpenapiContracts
  module Matchers
    autoload :MatchOpenapiDoc, 'openapi_contracts/matchers/match_openapi_doc'

    def match_openapi_doc(doc)
      MatchOpenapiDoc.new(doc)
    end
  end
end
