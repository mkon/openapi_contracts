module OpenapiContracts
  class Doc::Operation
    include Doc::WithParameters

    def initialize(path, schema)
      @path = path
      @schema = schema
      @responses = schema.navigate('responses').each.to_h do |status, subspec| # rubocop:disable Style/HashTransformValues
        [status, Doc::Response.new(subspec)]
      end
    end

    def responses
      @responses.each_value
    end

    def with_status(status)
      @responses[status]
    end
  end
end
