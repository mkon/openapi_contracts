module OpenapiContracts
  class Doc::Method
    def initialize(schema)
      @schema = schema
      @request_body = Doc::Request.new(schema.navigate('requestBody')) if schema['requestBody'].present?
      @responses = schema['responses'].to_h do |status, _|
        [status, Doc::Response.new(schema.navigate('responses', status))]
      end
    end

    attr_reader :request_body

    def responses
      @responses.each_value
    end

    def with_status(status)
      @responses[status]
    end
  end
end
