module OpenapiContracts
  class Doc
    autoload :Header,   'openapi_contracts/doc/header'
    autoload :Parser,   'openapi_contracts/doc/parser'
    autoload :Response, 'openapi_contracts/doc/response'
    autoload :Schema,   'openapi_contracts/doc/schema'

    def self.parse(dir)
      new Parser.call(dir)
    end

    def initialize(schema)
      @schema = Schema.new(schema)
    end

    delegate :dig, :fetch, :[], :at_path, to: :@schema

    def response_for(path, method, status)
      path = ['paths', path, method, 'responses', status]
      return unless dig(*path).present?

      Response.new(@schema.at_path(path))
    end
  end
end
