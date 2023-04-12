module OpenapiContracts::Validators
  class Body < Base
    private

    def validate
      if spec.no_content?
        @errors << 'Expected empty response body' if response.body.present?
      elsif !spec.supports_content_type?(response_content_type)
        @errors << "Undocumented response with content-type #{response_content_type.inspect}"
      else
        validate_schema
      end
    end

    def validate_schema
      schema = spec.schema_for(response_content_type)
      schemer = JSONSchemer.schema(schema.schema.merge('$ref' => schema.fragment))
      schemer.validate(JSON(response.body)).each do |err|
        @errors << error_to_message(err)
      end
    end

    def error_to_message(error)
      if error.key?('details')
        error['details'].to_a.map do |(key, val)|
          "#{key.humanize}: #{val} at #{error['data_pointer']}"
        end.to_sentence
      else
        "#{error['data'].inspect} at #{error['data_pointer']} does not match the schema"
      end
    end

    def response_content_type
      response.headers['Content-Type'].split(';').first
    end
  end
end