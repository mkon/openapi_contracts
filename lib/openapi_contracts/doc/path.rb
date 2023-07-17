module OpenapiContracts
  HTTP_METHODS = %w(get head post put delete connect options trace patch).freeze

  class Doc::Path
    def initialize(path, schema)
      @path = path
      @schema = schema
      @supported_methods = HTTP_METHODS & @schema.keys
    end

    def dynamic?
      @path.include?('{')
    end

    def matches?(path, method)
      @path == path || regexp_path.match(path) do |m|
        m.named_captures.each do |k, v|
          return false unless parameter_matches?(method, k, v)
        end
        true
      end
    end

    def operations
      @supported_methods.each.lazy.map { |m| Doc::Operation.new(@schema.navigate(m)) }
    end

    def parameters
      enum = @schema.navigate('parameters').each
      return [].each unless enum

      enum.lazy.map { |s| Doc::Parameter.new(s) }
    end

    def static?
      !dynamic?
    end

    def supports_method?(method)
      @supported_methods.include?(method)
    end

    def with_method(method)
      return unless supports_method?(method)

      Doc::Operation.new(@schema.navigate(method))
    end

    private

    def parameter_matches?(method, name, value)
      # Check path-wide parameters first
      return true if parameters.select(&:in_path?).find { |s| s.name == name }&.matches?(value)

      with_method(method)&.parameters&.find { |s| s.name == name }&.matches?(value)
    end

    def regexp_path
      re = /\{(\S+)\}/
      @path.gsub(re) { |placeholder|
        placeholder.match(re) { |m| "(?<#{m[1]}>[^/]*)" }
      }.then { |str| Regexp.new(str) }
    end
  end
end
