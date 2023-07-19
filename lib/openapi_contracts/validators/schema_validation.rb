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
      if error.key?('details')
        error['details'].to_a.map { |(key, val)|
          "#{key.humanize}: #{val} at #{error['data_pointer']}"
        }.to_sentence
      else
        "#{error['data'].inspect} at #{error['data_pointer']} does not match the schema"
      end
    end
  end
end
