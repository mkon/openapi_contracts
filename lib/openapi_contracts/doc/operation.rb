module OpenapiContracts
  class Doc::Operation
    include Doc::WithParameters

    attr_reader :path

    def initialize(path, spec)
      @path = path
      @spec = spec
      @responses = spec.navigate('responses').each.to_h do |status, subspec|
        [status, Doc::Response.new(status, subspec)]
      end
    end

    def verb
      @spec.pointer[2]
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
