require 'active_support'
require 'active_support/core_ext/array'
require 'active_support/core_ext/module'
require 'active_support/core_ext/string'

require 'json_schemer'
require 'yaml'

module OpenapiContracts
  autoload :Doc, 'openapi_contracts/doc'
end

if defined?(RSpec)
  RSpec::Matchers.define :match_openapi_doc do |doc, options = {}| # rubocop:disable Metrics/BlockLength
    match do |response|
      @errors = []
      @response = response
      @response_spec ||= doc.response_for(
        options.fetch(:path, @response.request.path),
        @response.request.request_method.downcase,
        @response.status.to_s
      )
      response_documented? && http_status_matches? && [headers_match?, body_matches?].all?
      @errors.empty?
    end

    description do
      desc = 'to match the openapi schema'
      desc << " with #{http_status_desc(@status)}" if @status
      desc
    end

    failure_message do |_reponse|
      @errors.map { |e| "* #{e}" }.join("\n")
    end

    def with_http_status(status)
      if status.is_a? Symbol
        @status = Rack::Utils::SYMBOL_TO_STATUS_CODE[status]
      else
        @status = status
      end
      self
    end

    private

    def response_desc
      "#{@response.request.request_method} #{@response.request.path}"
    end

    def response_content_type
      @response.headers['Content-Type'].split(';').first
    end

    def headers_match?
      @response_spec.headers.each do |header|
        value = @response.headers[header.name]
        if value.blank?
          @errors << "Missing header #{header.name}" if header.required?
        elsif !JSONSchemer.schema(header.schema).valid?(value)
          @errors << "Header #{header.name} does not match"
        end
      end
      @errors.empty?
    end

    def http_status_desc(status = nil)
      status ||= @response.status
      "http status #{Rack::Utils::HTTP_STATUS_CODES[status]} (#{status})"
    end

    def http_status_matches?
      if @status.present? && @status != @response.status
        @errors << "Response has #{http_status_desc}"
        false
      else
        true
      end
    end

    def body_matches?
      if @response_spec.no_content?
        @errors << 'Expected empty response body' if @response.body.present?
      elsif !@response_spec.supports_content_type?(response_content_type)
        @errors << "Undocumented response with content-type #{response_content_type.inspect}"
      else
        @schema = @response_spec.schema_for(response_content_type)
        schemer = JSONSchemer.schema(@schema.schema.merge('$ref' => @schema.fragment))
        schemer.validate(JSON(@response.body)).each do |err|
          @errors << error_to_message(err)
        end
      end
      @errors.empty?
    end

    def error_to_message(error)
      if error.key?('details')
        error['details'].to_a.map do |(key, val)|
          "#{key.humanize}: #{val} at #{error['data_pointer']}"
        end.to_sentence
      else
        "#{error['data'].inspect} at #{error['data_pointer']} does not match the schema"
      end
    end

    def response_documented?
      return true if @response_spec

      @errors << "Undocumented request/response for #{response_desc.inspect} with #{http_status_desc}"
      false
    end
  end
end
