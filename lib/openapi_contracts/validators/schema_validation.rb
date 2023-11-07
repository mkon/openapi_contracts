module OpenapiContracts::Validators
  module SchemaValidation
    module_function

    def error_to_message(error)
      msg = error['error']
      msg.sub!(/^value/, error['data'].to_json) if error['data'].to_json.length < 50
      msg
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
    rescue JSONSchemer::UnknownRef => e
      # This usually happens when discriminators encounter unknown types
      ["Could not resolve pointer #{e.message.inspect}"]
    end
  end
end
