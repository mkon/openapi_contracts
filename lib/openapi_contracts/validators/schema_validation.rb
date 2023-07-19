module OpenapiContracts::Validators
  module SchemaValidation
    module_function

    def validate_schema(schema, data)
      schemer = JSONSchemer.schema(schema.merge('$schema' => 'http://json-schema.org/draft-04/schema#'))
      schemer.validate(data).map do |err|
        error_to_message(err)
      end
    end

    def error_to_message(error)
      pointer = " at #{error['data_pointer']}" if error['data_pointer'].present?
      if error.key?('details')
        error['details'].to_a.map { |(key, val)|
          "#{key.humanize}: #{val}#{pointer}"
        }.to_sentence
      else
        "#{error['data'].inspect}#{pointer} does not match the schema"
      end
    end
  end
end
