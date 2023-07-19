module OpenapiContracts::Validators
  class Body < Base
    include SchemaValidation

    private

    def json_for_validation
      # ActionDispatch::Response body is a plain string, while Rack::Response returns an array
      JSON(Array.wrap(response.body).join)
    end

    def schema_for_validation
      schema = spec.schema_for(response_content_type)
      schema.raw.merge('$ref' => schema.fragment)
    end

    def spec
      @spec ||= operation.response_for_status(response.status)
    end

    def validate
      if spec.no_content?
        @errors << 'Expected empty response body' if response.body.present?
      elsif !spec.supports_content_type?(response_content_type)
        @errors << "Undocumented response with content-type #{response_content_type.inspect}"
      else
        @errors += validate_schema(schema_for_validation, json_for_validation)
      end
    end

    def response_content_type
      response.content_type&.split(';')&.first
    end
  end
end
