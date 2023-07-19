module OpenapiContracts::Validators
  class Headers < Base
    private

    def spec
      @spec ||= operation.response_for_status(response.status)
    end

    def validate
      spec.headers.each do |header|
        value = response.headers[header.name]
        if value.blank?
          @errors << "Missing header #{header.name}" if header.required?
        elsif !JSONSchemer.schema(header.schema).valid?(value)
          @errors << "Header #{header.name} does not match"
        end
      end
    end
  end
end
