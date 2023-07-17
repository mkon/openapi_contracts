module OpenapiContracts
  class Match
    attr_reader :errors

    def initialize(doc, response, options = {})
      @doc = doc
      @response = response
      @options = options
    end

    def valid?
      return @errors.empty? if instance_variable_defined?(:@errors)

      @errors = matchers.call
      @errors.empty?
    end

    private

    def response_spec
      @doc.response_for(path, method, status)
    end

    def request_spec
      @doc.request_for(path, method)
    end

    def matchers
      env = Env.new(response_spec, @response, @options[:status], match_request_body?, request_spec)
      Validators::ALL.reverse
                     .reduce(->(err) { err }) { |s, m| m.new(s, env) }
    end

    def match_request_body?
      @options.fetch(:request_body, false)
    end

    def path
      @options.fetch(:path, @response.request.path)
    end

    def method
      @response.request.request_method.downcase
    end

    def status
      @response.status.to_s
    end
  end
end
