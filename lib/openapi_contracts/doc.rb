module OpenapiContracts
  class Doc
    def self.parse(dir)
      new Parser.call(dir)
    end

    def initialize(spec, pointer = [])
      @spec = spec
    end

    delegate :dig, to: :@spec

    def response_for(path, method, status)
      Response.new dig('paths', path, method, 'responses', status)
    end
  end
end
