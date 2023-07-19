module OpenapiContracts::Validators
  class Documented < Base
    self.final = true

    private

    def validate
      response_missing unless spec
      request_missing if match_request_body? && !request_body
    end

    def response_missing
      status_desc = http_status_desc(response.status)
      @errors << "Undocumented response for #{response_desc.inspect} with #{status_desc}"
    end

    def request_missing
      @errors << "Undocumented request body for #{response_desc.inspect}"
    end

    def response_desc
      "#{request.request_method} #{request.path}"
    end
  end
end
