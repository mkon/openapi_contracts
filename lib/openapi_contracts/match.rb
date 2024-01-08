module OpenapiContracts
  class Match
    DEFAULT_OPTIONS = {request_body: false}.freeze
    MIN_REQUEST_ANCESTORS = %w(Rack::Request::Env Rack::Request::Helpers).freeze
    MIN_RESPONSE_ANCESTORS = %w(Rack::Response::Helpers).freeze

    attr_reader :errors

    def initialize(doc, response, options = {})
      @doc = doc
      @response = response
      @request = options.delete(:request) { response.request }
      @options = DEFAULT_OPTIONS.merge(options)
      raise ArgumentError, "#{@response} must be compatible with Rack::Response::Helpers" unless response_compatible?
      raise ArgumentError, "#{@request} must be compatible with Rack::Request::{Env,Helpers}" unless request_compatible?
    end

    def valid?
      return @errors.empty? if instance_variable_defined?(:@errors)

      @errors = matchers.call
      @doc.coverage.increment!(operation.path.to_s, request_method, status, media_type) if collect_coverage?
      @errors.empty?
    end

    private

    def collect_coverage?
      OpenapiContracts.collect_coverage && @request.present? && @errors.empty? && !@options[:nocov]
    end

    def media_type
      @response.headers['Content-Type']&.split(';')&.first || 'no_content'
    end

    def matchers
      env = Env.new(
        options:   @options,
        operation:,
        request:   @request,
        response:  @response
      )
      validators = Validators::ALL.dup
      validators.delete(Validators::HttpStatus) unless @options[:status]
      validators.delete(Validators::RequestBody) unless @options[:request_body]
      validators.reverse
                .reduce(->(err) { err }) { |s, m| m.new(s, env) }
    end

    def operation
      @operation ||= @doc.operation_for(path, request_method)
    end

    def request_compatible?
      ancestors = @request.class.ancestors.map(&:to_s)
      MIN_REQUEST_ANCESTORS.all? { |s| ancestors.include?(s) }
    end

    def response_compatible?
      ancestors = @response.class.ancestors.map(&:to_s)
      MIN_RESPONSE_ANCESTORS.all? { |s| ancestors.include?(s) }
    end

    def request_method
      @request.request_method.downcase
    end

    def path
      @options.fetch(:path, @request.path)
    end

    def status
      @response.status.to_s
    end
  end
end
