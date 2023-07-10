module OpenapiContracts
  class Doc::Parameter
    attr_reader :schema

    def initialize(spec)
      @spec = spec
      options = spec.to_h
      @name = options[:name]
      @in = options[:in]
      @required = options[:required]
    end

    def matches?(value)
      case @spec.dig('schema', 'type')
      when 'integer'
        integer_parameter_matches?(value)
      when 'number'
        number_parameter_matches?(value)
      else
        schemer.valid?(value)
      end
    end

    private

    def schemer
      @schemer ||= begin
        schema = @spec.navigate('schema')
        JSONSchemer.schema(schema.raw.merge('$ref' => schema.fragment, '$schema' => 'http://json-schema.org/draft-04/schema#'))
      end
    end

    def integer_parameter_matches?(value)
      return false unless /^-?\d+$/.match?(value)

      schemer.valid?(value.to_i)
    end

    def number_parameter_matches?(value)
      return false unless /^-?(\d+\.)?\d+$/.match?(value)

      schemer.valid?(value.to_f)
    end
  end
end
