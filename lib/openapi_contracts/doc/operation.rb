module OpenapiContracts
  class Doc::Operation
    include Doc::WithParameters

    def initialize(path, spec)
      @path = path
      @spec = spec
      @responses = spec.navigate('responses').each.to_h do |status, subspec| # rubocop:disable Style/HashTransformValues
        [status, Doc::Response.new(subspec)]
      end
    end

    def request_body
      return @request_body if instance_variable_defined?(:@request_body)

      @request_body = @spec.navigate('requestBody').presence&.then { |s| Doc::Request.new(s) }
    end

    def responses
      @responses.each_value
    end

    def response_for_status(status)
      @responses[status.to_s]
    end
  end
end
