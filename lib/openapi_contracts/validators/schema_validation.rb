module OpenapiContracts::Validators
  module SchemaValidation
    module_function

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

    def schema_draft_version(schema)
      if schema.openapi_version.blank? || schema.openapi_version < Gem::Version.new('3.1')
        JSONSchemer.openapi30
      else
        JSONSchemer.openapi31
      end
    end

    def validation_schemer(schema)
      schemer = JSONSchemer.schema(schema.raw, meta_schema: schema_draft_version(schema))
      if schema.pointer.any?
        schemer.ref(schema.fragment)
      else
        schemer
      end
    end

    def validate_schema(schema, data)
      validation_schemer(schema).validate(data).map do |err|
        error_to_message(err)
      end
    end
  end
end
