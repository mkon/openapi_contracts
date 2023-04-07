module OpenapiContracts::Matchers
  class Documented < Base
    self.final = true

    private

    def validate
      return if spec

      status_desc = http_status_desc(response.status)
      @errors << "Undocumented request/response for #{response_desc.inspect} with #{status_desc}"
    end

    def response_desc
      "#{response.request.request_method} #{response.request.path}"
    end
  end
end
