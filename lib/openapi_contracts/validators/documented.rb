module OpenapiContracts::Validators
  class Documented < Base
    self.final = true

    private

    def validate
      request_missing if request_body_required? && !request_body
      spec ? return : response_missing
    end

    def response_missing
      status_desc = http_status_desc(response.status)
      @errors << "Undocumented response for #{response_desc.inspect} with #{status_desc}"
    end

    def request_missing
      @errors << "Undocumented request body for #{response_desc.inspect}"
    end

    def response_desc
      "#{response.request.request_method} #{response.request.path}"
    end
  end
end
