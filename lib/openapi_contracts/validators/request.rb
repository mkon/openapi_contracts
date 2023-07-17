module OpenapiContracts::Validators
  class Request < Base
    private

    def validate
      validate_schema if match_request_body?
    end

    def validate_schema
      if !request_body
        @errors << 'No request body found'
      elsif !request_body.supports_content_type?(request_content_type)
        @errors << "Undocumented request with content-type #{request_content_type.inspect}"
      else
        schema = request_body.schema_for(request_content_type)
        # Trick JSONSchemer into validating only against the request body schema
        schemer = JSONSchemer.schema(schema.raw.merge('$ref' => schema.fragment, '$schema' => 'http://json-schema.org/draft-04/schema#'))
        schemer.validate(JSON(request_payload)).each do |err|
          @errors << error_to_message(err)
        end
      end
    end

    def request_payload
      response.request.env['PARAMS'] || response.request.body.read
    end

    def error_to_message(error)
      if error.key?('details')
        error['details'].to_a.map { |(key, val)|
          "#{key.humanize}: #{val} at #{error['data_pointer']}"
        }.to_sentence
      else
        "#{error['data'].inspect} at #{error['data_pointer']} does not match the request schema"
      end
    end

    def request_content_type
      response.headers['Content-Type'].split(';').first
    end
  end
end
