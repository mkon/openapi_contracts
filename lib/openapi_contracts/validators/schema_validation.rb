module OpenapiContracts::Validators
  module SchemaValidation
    module_function

    def build_validation_schema(schema)
      schema.raw.merge(
        '$ref'    => schema.fragment,
        '$schema' => schema_draft_version(schema)
      )
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

    def schema_draft_version(schema)
      if schema.openapi_version.blank? || schema.openapi_version < Gem::Version.new('3.1')
        # Closest compatible version is actually draft 5 but not supported by json-schemer
        'http://json-schema.org/draft-04/schema#'
      else
        # >= 3.1 is actually comptable with 2020-12 but not yet supported by json-schemer
        'http://json-schema.org/draft-07/schema#'
      end
    end

    def validate_schema(schema, data)
      schemer = JSONSchemer.schema(build_validation_schema(schema))
      schemer.validate(data).map do |err|
        error_to_message(err)
      end
    end
  end
end
