module TestHelper
  class ResponseBuilder
    attr_reader :headers

    def initialize(status, headers, body)
      @status = status
      @headers = headers
      @body = body
    end

    def for_request(method, path)
      TestResponse.new(
        Rack::MockResponse.new(@status, @headers, @body),
        Rack::Request.new({'PATH_INFO' => path, 'REQUEST_METHOD' => method.to_s.upcase})
      )
    end
  end

  def setup_response(status, headers, body, request_env)
    TestResponse.new(
      Rack::MockResponse.new(status, headers, body),
      Rack::Request.new(request_env)
    )
  end

  def json_response(status, json)
    ResponseBuilder.new(
      status,
      {
        'Content-Type' => 'application/json',
        'X-Request-Id' => 'some-id'
      },
      JSON.dump(json)
    )
  end
end
