module OpenapiContracts
  module Helper
    def http_status_desc(status)
      "http status #{Rack::Utils::HTTP_STATUS_CODES[status]} (#{status})"
    end
  end
end
