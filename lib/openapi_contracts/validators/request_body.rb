module OpenapiContracts::Validators
  class RequestBody < Base
    include SchemaValidation

    private

    delegate :media_type, to: :request
    delegate :request_body, to: :operation

    def data_for_validation
      # Support "*/json" or "*/*+json"
      raise ArgumentError, "#{media_type.inspect} is not supported yet" unless %r{/|\+json$} =~ media_type

      request.body.rewind
      JSON(request.body.read)
    end

    def schema_for_validation
      schema = request_body.schema_for(media_type)
      schema.raw.merge('$ref' => schema.fragment)
    end

    def validate
      if !request_body
        @errors << "Undocumented request body for #{response_desc.inspect}"
      elsif !request_body.supports_media_type?(media_type)
        @errors << "Undocumented request with media-type #{media_type.inspect}"
      else
        @errors += validate_schema(schema_for_validation, data_for_validation)
      end
    end
  end
end
