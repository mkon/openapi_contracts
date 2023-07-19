module OpenapiContracts::Validators
  class RequestBody < Base
    include SchemaValidation

    private

    delegate :request_body, to: :operation

    def json_for_validation
      request.body.rewind
      JSON(request.body.read)
    end

    def schema_for_validation
      schema = request_body.schema_for(request.media_type)
      schema.raw.merge('$ref' => schema.fragment)
    end

    def validate
      if !request_body
        @errors << "Undocumented request body for #{response_desc.inspect}"
      elsif !request_body.supports_media_type?(request.media_type)
        @errors << "Undocumented request with media-type #{request.media_type.inspect}"
      else
        @errors += validate_schema(schema_for_validation, json_for_validation)
      end
    end
  end
end
