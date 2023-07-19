module OpenapiContracts::Validators
  class HttpStatus < Base
    self.final = true

    private

    def validate
      return if options[:status] == response.status

      @errors << "Response has #{http_status_desc(response.status)}"
    end
  end
end
