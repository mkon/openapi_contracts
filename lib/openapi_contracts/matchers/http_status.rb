module OpenapiContracts::Matchers
  class HttpStatus < Base
    self.final = true

    private

    def validate
      return if expected_status.blank? || expected_status == response.status

      @errors << "Response has #{http_status_desc}"
    end

    def http_status_desc
      "http status #{Rack::Utils::HTTP_STATUS_CODES[response.status]} (#{response.status})"
    end
  end
end
