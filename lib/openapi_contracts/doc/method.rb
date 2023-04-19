module OpenapiContracts
  class Doc::Method
    def initialize(schema)
      @schema = schema
      @responses = schema['responses'].to_h do |status, _|
        [status, Doc::Response.new(schema.navigate('responses', status))]
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
