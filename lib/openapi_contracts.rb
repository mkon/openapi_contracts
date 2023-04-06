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

  # Defines order of matching
  MATCHERS = [
    OpenapiContracts::Matchers::HttpStatus,
    OpenapiContracts::Matchers::Body,
    OpenapiContracts::Matchers::Headers
  ].freeze

  Env = Struct.new(:spec, :response, :expected_status)
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
      env = OpenapiContracts::Env.new(@response_spec, response, @status)
      stack = OpenapiContracts::MATCHERS
              .reverse
              .reduce(->(err) { err }) { |s, m| m.new(s, env) }
      @errors = stack.call(@errors) if response_documented?
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

    def response_documented?
      return true if @response_spec

      @errors << "Undocumented request/response for #{response_desc.inspect} with #{http_status_desc}"
      false
    end
  end
end
