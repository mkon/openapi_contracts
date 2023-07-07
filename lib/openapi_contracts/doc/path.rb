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
      parameter = @schema['parameters']&.find { |p| p['name'] == name && p['in'] == 'path' }

      return false unless parameter

      case parameter.dig('schema', 'type')
      when 'integer'
        integer_parameter_matches?(parameter, value)
      when 'number'
        number_parameter_matches?(parameter, value)
      when 'string'
        string_parameter_matches?(parameter, value)
      else
        # Not yet implemented
        false
      end
    end

    def regexp_path
      re = /\{(\S+)\}/
      @path.gsub(re) { |placeholder|
        placeholder.match(re) { |m| "(?<#{m[1]}>[^/]*)" }
      }.then { |str| Regexp.new(str) }
    end

    def integer_parameter_matches?(parameter, value)
      return false unless /^-?\d+$/.match?(value)

      parsed = value.to_i
      return false unless minimum_number_matches?(parameter, parsed)
      return false unless maximum_number_matches?(parameter, parsed)

      true
    end

    def number_parameter_matches?(parameter, value)
      return false unless /^-?(\d+\.)?\d+$/.match?(value)

      parsed = value.to_f
      return false unless minimum_number_matches?(parameter, parsed)
      return false unless maximum_number_matches?(parameter, parsed)

      true
    end

    def minimum_number_matches?(parameter, value)
      if (min = parameter.dig('schema', 'minimum'))
        if parameter.dig('schema', 'exclusiveMinimum')
          return false if value <= min
        elsif value < min
          return false
        end
      end
      true
    end

    def maximum_number_matches?(parameter, value)
      if (max = parameter.dig('schema', 'maximum'))
        if parameter.dig('schema', 'exclusiveMaximum')
          return false if value >= max
        elsif value > max
          return false
        end
      end
      true
    end

    def string_parameter_matches?(parameter, value)
      if (pat = parameter.dig('schema', 'pattern'))
        Regexp.new(pat).match?(value)
      else
        if (min = parameter.dig('schema', 'minLength')) && (value.length < min)
          return false
        end

        if (max = parameter.dig('schema', 'maxLength')) && (value.length > max)
          return false
        end

        true
      end
    end

    def known_http_methods
      # https://developer.mozilla.org/en-US/docs/Web/HTTP/Methods
      %w(get head post put delete connect options trace patch).freeze
    end
  end
end
