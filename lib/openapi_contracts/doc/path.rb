module OpenapiContracts
  class Doc::Path
    def initialize(path, schema)
      @path = path
      @schema = schema

      @methods = (known_http_methods & @schema.keys).to_h do |method|
        [method, Doc::Method.new(@schema.navigate(method))]
      end
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

    def methods
      @methods.each_value
    end

    def parameters
      enum = @schema.navigate('parameters').each
      return [].each unless enum

      enum.map { |s| Doc::Parameter.new(s) }
    end

    def static?
      !dynamic?
    end

    def with_method(method)
      @methods[method]
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

    def known_http_methods
      # https://developer.mozilla.org/en-US/docs/Web/HTTP/Methods
      %w(get head post put delete connect options trace patch).freeze
    end
  end
end
