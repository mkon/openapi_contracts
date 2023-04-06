require 'active_support'
require 'active_support/core_ext/array'
require 'active_support/core_ext/class'
require 'active_support/core_ext/module'
require 'active_support/core_ext/string'

require 'json_schemer'
require 'yaml'

module OpenapiContracts
  autoload :Doc,      'openapi_contracts/doc'
  autoload :Matchers, 'openapi_contracts/matchers'
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
      matchers = [
        OpenapiContracts::Matchers::Body,
        OpenapiContracts::Matchers::Headers
      ]
      stack = matchers.reverse.reduce(->(err) { err }) { |s, m| m.new(s, @response_spec, response) }
      @errors = stack.call(@errors) if response_documented? && http_status_matches?
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

    def response_documented?
      return true if @response_spec

      @errors << "Undocumented request/response for #{response_desc.inspect} with #{http_status_desc}"
      false
    end
  end
end
