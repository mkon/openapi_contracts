module OpenapiContracts
  class Validator
    attr_reader :errors

    def initialize(doc, response, options = {})
      @doc = doc
      @response = response
      @options = options
    end

    def valid?
      return @errors.empty? if instance_variable_defined?(:@errors)

      spec = lookup_api_spec(doc, options, response)
      env = Env.new(spec, response, options[:status])
      stack = MATCHERS
              .reverse
              .reduce(->(err) { err }) { |s, m| m.new(s, env) }
      @errors = stack.call
      @errors.empty?
    end
  end
end
