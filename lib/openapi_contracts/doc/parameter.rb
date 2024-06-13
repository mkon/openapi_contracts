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
      converted = OpenapiParameters::Converter.convert(value, schema_for_validation)
      errors = schemer.validate(converted)
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

    def schemer
      @schemer ||= Validators::SchemaValidation.validation_schemer(schema_for_validation)
    end
  end
end
