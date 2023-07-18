module OpenapiContracts
  class Match
    MIN_REQUEST_ANCESTORS = %w(Rack::Request::Env Rack::Request::Helpers).freeze
    MIN_RESPONSE_ANCESTORS = %w(Rack::Response::Helpers).freeze

    attr_reader :errors

    def initialize(doc, response, options = {})
      @doc = doc
      @response = response
      @request = options.delete(:request) { response.request }
      @options = options
      raise ArgumentError, "#{@response} must be compatible with Rack::Response::Helpers" unless response_compatible?
      raise ArgumentError, "#{@request} must be compatible with Rack::Request::{Env,Helpers}" unless request_compatible?
    end

    def valid?
      return @errors.empty? if instance_variable_defined?(:@errors)

      @errors = matchers.call
      @errors.empty?
    end

    private

    def request_compatible?
      ancestors = @request.class.ancestors.map(&:to_s)
      MIN_REQUEST_ANCESTORS.all? { |s| ancestors.include?(s) }
    end

    def response_compatible?
      ancestors = @response.class.ancestors.map(&:to_s)
      MIN_RESPONSE_ANCESTORS.all? { |s| ancestors.include?(s) }
    end

    def response_spec
      @doc.response_for(path, method, status)
    end

    def request_spec
      @doc.request_for(path, method)
    end

    def matchers
      env = Env.new(
        spec:                response_spec,
        response:            @response,
        request:             @request,
        expected_status:     @options[:status],
        match_request_body?: match_request_body?,
        request_body:        request_spec
      )
      Validators::ALL.reverse
                     .reduce(->(err) { err }) { |s, m| m.new(s, env) }
    end

    def match_request_body?
      @options.fetch(:request_body, false)
    end

    def path
      @options.fetch(:path, @request.path)
    end

    def method
      @request.request_method.downcase
    end

    def status
      @response.status.to_s
    end
  end
end
