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

    def matches?(path)
      @path == path || regexp_path.match(path) do |m|
        m.named_captures.each do |k, v|
          return false unless parameter_matches?(k, v)
        end
        true
      end
    end

    def methods
      @methods.each_value
    end

    def static?
      !dynamic?
    end

    def with_method(method)
      @methods[method]
    end

    private

    def parameter_matches?(name, value)
      parameter = Array.wrap(@schema['parameters'])
                       .map.with_index { |_spec, index| @schema.navigate('parameters', index.to_s).follow_refs }
                       .find { |s| s['name'] == name && s['in'] == 'path' }
                      &.then { |s| Doc::Parameter.new(s) }
      return false unless parameter

      parameter.matches?(value)
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
