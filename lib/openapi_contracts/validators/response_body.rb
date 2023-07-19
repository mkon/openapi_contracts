module OpenapiContracts::Validators
  class ResponseBody < Base
    include SchemaValidation

    private

    delegate :media_type, to: :response

    def data_for_validation
      # ActionDispatch::Response body is a plain string, while Rack::Response returns an array
      OpenapiContracts::PayloadParser.parse(media_type, Array.wrap(response.body).join)
    end

    def schema_for_validation
      schema = spec.schema_for(media_type)
      schema.raw.merge('$ref' => schema.fragment)
    end

    def spec
      @spec ||= operation.response_for_status(response.status)
    end

    def validate
      if spec.no_content?
        @errors << 'Expected empty response body' if response.body.present?
      elsif !spec.supports_media_type?(media_type)
        @errors << "Undocumented response with content-type #{media_type.inspect}"
      else
        @errors += validate_schema(schema_for_validation, data_for_validation)
      end
    end
  end
end
