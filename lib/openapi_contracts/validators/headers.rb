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
        value = value.join('\n') if value.is_a?(Array)

        if value.blank?
          @errors << "Missing header #{header.name}" if header.required?
        elsif !JSONSchemer.schema(header.schema).valid?(value)
          @errors << "Header #{header.name} does not match"
        end
      end
    end
  end
end
