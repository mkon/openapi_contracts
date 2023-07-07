module OpenapiContracts
  class Doc::Parameter
    attr_reader :schema

    def initialize(options)
      @name = options[:name]
      @in = options[:in]
      @required = options[:required]
      @schema = options[:schema]
    end

    def matches?(value)
      case schema['type']
      when 'integer'
        integer_parameter_matches?(value)
      when 'number'
        number_parameter_matches?(value)
      when 'string'
        string_parameter_matches?(value)
      else
        # Not yet implemented
        false
      end
    end

    private

    def integer_parameter_matches?(value)
      return false unless /^-?\d+$/.match?(value)

      parsed = value.to_i
      return false unless minimum_number_matches?(parsed)
      return false unless maximum_number_matches?(parsed)

      true
    end

    def number_parameter_matches?(value)
      return false unless /^-?(\d+\.)?\d+$/.match?(value)

      parsed = value.to_f
      return false unless minimum_number_matches?(parsed)
      return false unless maximum_number_matches?(parsed)

      true
    end

    def minimum_number_matches?(value)
      if (min = schema['minimum'])
        if schema['exclusiveMinimum']
          return false if value <= min
        elsif value < min
          return false
        end
      end
      true
    end

    def maximum_number_matches?(value)
      if (max = schema['maximum'])
        if schema['exclusiveMaximum']
          return false if value >= max
        elsif value > max
          return false
        end
      end
      true
    end

    def string_parameter_matches?(value)
      if (pat = schema['pattern'])
        Regexp.new(pat).match?(value)
      else
        if (min = schema['minLength']) && (value.length < min)
          return false
        end

        if (max = schema['maxLength']) && (value.length > max)
          return false
        end

        true
      end
    end
  end
end
