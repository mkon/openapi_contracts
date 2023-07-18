module OpenapiContracts
  class Match
    attr_reader :errors

    def initialize(doc, response, options = {})
      @doc = doc
      @response = response
      @request = options.delete(:request) { response.request }
      @options = options
    end

    def valid?
      return @errors.empty? if instance_variable_defined?(:@errors)

      @errors = matchers.call
      @errors.empty?
    end

    private

    def lookup_api_spec
      @doc.response_for(
        @options.fetch(:path, @request.path),
        @request.request_method.downcase,
        @response.status.to_s
      )
    end

    def matchers
      env = Env.new(
        spec:            lookup_api_spec,
        response:        @response,
        request:         @request,
        expected_status: @options[:status]
      )
      Validators::ALL.reverse
                     .reduce(->(err) { err }) { |s, m| m.new(s, env) }
    end
  end
end
