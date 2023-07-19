module OpenapiContracts::Validators
  # Purpose of this validator
  # * ensure the operation is documented (combination http-method + path)
  # * ensure the response-status is documented on the operation
  class Documented < Base
    self.final = true

    private

    def validate
      return operation_missing unless operation

      response_missing unless operation.response_for_status(response.status)
    end

    def operation_missing
      @errors << "Undocumented operation for #{response_desc.inspect}"
    end

    def response_missing
      status_desc = http_status_desc(response.status)
      @errors << "Undocumented response for #{response_desc.inspect} with #{status_desc}"
    end
  end
end
