module OpenapiContracts
  class Doc::Parameter
    attr_reader :name, :in, :schema

    def initialize(spec)
      @spec = spec
      options = spec.to_h
      @name = options['name']
      @in = options['in']
      @required = options['required']
    end

    def in_path?
      @in == 'path'
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
      @schemer ||= Validators::SchemaValidation.validation_schemer(@spec.navigate('schema'))
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
