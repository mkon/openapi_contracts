module OpenapiContracts
  module Matchers
    class MatchOpenapiDoc
      def initialize(doc)
        @doc = doc
        @errors = []
      end

      def with_http_status(status)
        if status.is_a? Symbol
          @status = Rack::Utils::SYMBOL_TO_STATUS_CODE[status]
        else
          @status = code
        end
        self
      end

      def matches?(response)
        @response = response
        http_status_matches? && [headers_match?, body_matches?].all?
      end

      def description
        desc = 'to match the openapi schema'
        desc << " with #{http_status_desc(@status)}" if @status
        desc
      end

      def failure_message
        message = @errors.map { |e| "* #{e}" }.join("\n")
        return message #unless @schema

        message << "\n\nAllowed Schema:\n"
        message << YAML.dump(@schema)
      end

      def failure_message_when_negated
        'Expected to not match the Openapi Schema, but did'
      end

      private

      def response_spec
        @response_spec ||= @doc.response_for(@response.request.path, @response.request.request_method.downcase, @response.status.to_s)
      end

      def response_content_type
        @response.headers['Content-Type'].split(';').first
      end

      def headers_match?
        response_spec.headers.each do |header|
          value = @response.headers[header.name]
          if value.blank?
            @errors << "Missing header #{header.name}" if header.required?
          elsif !JSON::Validator.validate(header.schema, value)
            @errors << "Header #{header.name} does not match schema"
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
        if !response_spec
          @errors << "Undocumented response with #{http_status_desc}"
        elsif response_spec.no_content?
          @errors << "Expected empty response body" if @response.body.present?
        elsif !response_spec.supports_content_type?(response_content_type)
          @errors << "Undocumented response with content-type #{response_content_type.inspect}"
        else
          @schema = response_spec.schema_for(response_content_type)
          @errors += JSON::Validator.fully_validate(@schema, JSON(@response.body))
        end
        @errors.empty?
      end
    end
  end
end
