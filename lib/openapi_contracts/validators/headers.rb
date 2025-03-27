module OpenapiContracts::Validators
  class Headers < Base
    private

    def spec
      @spec ||= operation.response_for_status(response.status)
    end

    def validate
      spec.headers.each do |header|
        value = response.headers[header.name]

        # Rack 3.0.0 returns an Array for multi-value headers. OpenAPI doesn't
        # support multi-value headers, so we join them into a single string.
        #
        # @see https://github.com/rack/rack/issues/1598
        value = value.join("\n") if value.is_a?(Array)

        if value.blank?
          @errors << "Missing header #{header.name}" if header.required?
        else
          schemer = JSONSchemer.schema(header.schema)
          unless schemer.valid?(value)
            validation_errors = schemer.validate(value).to_a
            @errors << validation_error_message(header, value, validation_errors)
          end
        end
      end
    end

    def validation_error_message(header, value, error_array)
      if error_array.empty?
        "Header #{header.name} does not match schema"
      else
        error_array.map { |error|
          error_message = "Header #{header.name} validation error: #{error['error']}"
          truncated_value = value.to_s.truncate(100)
          error_message + " (value: #{truncated_value})"
        }.join("\n")
      end
    end
  end
end
