module OpenapiContracts
  class Doc
    autoload :Header,   'openapi_contracts/doc/header'
    autoload :Parser,   'openapi_contracts/doc/parser'
    autoload :Response, 'openapi_contracts/doc/response'

    def self.parse(dir)
      new Parser.call(dir)
    end

    def initialize(spec, pointer = [])
      @spec = spec
    end

    delegate :dig, :fetch, :[], to: :@spec

    def response_for(path, method, status)
      dig('paths', path, method, 'responses', status)&.then { |d| Response.new(d) }
    end
  end
end
