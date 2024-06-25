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

    def in_query?
      @in == 'query'
    end

    def matches?(value)
      errors = schemer.validate(convert_value(value))
      # debug errors.to_a here
      errors.none?
    end

    def required?
      @required == true
    end

    def schema_for_validation
      @spec.navigate('schema')
    end

    private

    def convert_value(original)
      OpenapiParameters::Converter.convert(original, schema_for_validation)
    rescue StandardError
      original
    end

    def schemer
      @schemer ||= Validators::SchemaValidation.validation_schemer(schema_for_validation)
    end
  end
end
