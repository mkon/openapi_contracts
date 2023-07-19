module OpenapiContracts::Validators
  class Request < Base
    include SchemaValidation

    private

    delegate :request_body, to: :operation

    def json_for_validation
      request.body.rewind
      JSON(request.body.read)
    end

    def schema_for_validation
      schema = request_body.schema_for(request_content_type)
      schema.raw.merge('$ref' => schema.fragment)
    end

    def validate
      if !request_body
        @errors << "Undocumented request body for #{response_desc.inspect}"
      elsif !request_body.supports_content_type?(request_content_type)
        @errors << "Undocumented request with content-type #{request_content_type.inspect}"
      else
        @errors += validate_schema(schema_for_validation, json_for_validation)
      end
    end

    def request_content_type
      request.content_type&.split(';')&.first
    end
  end
end
