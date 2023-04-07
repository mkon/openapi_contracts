require 'active_support'
require 'active_support/core_ext/array'
require 'active_support/core_ext/class'
require 'active_support/core_ext/module'
require 'active_support/core_ext/string'

require 'json_schemer'
require 'yaml'

module OpenapiContracts
  autoload :Helper,   'openapi_contracts/helper'
  autoload :Doc,      'openapi_contracts/doc'
  autoload :Matchers, 'openapi_contracts/matchers'

  # Defines order of matching
  MATCHERS = [
    Matchers::Documented,
    Matchers::HttpStatus,
    Matchers::Body,
    Matchers::Headers
  ].freeze

  Env = Struct.new(:spec, :response, :expected_status)
end

if defined?(RSpec)
  RSpec::Matchers.define :match_openapi_doc do |doc, options = {}| # rubocop:disable Metrics/BlockLength
    include OpenapiContracts::Helper

    match do |response|
      spec = lookup_api_spec(doc, options, response)
      env = OpenapiContracts::Env.new(spec, response, @status)
      stack = OpenapiContracts::MATCHERS
              .reverse
              .reduce(->(err) { err }) { |s, m| m.new(s, env) }
      @errors = stack.call
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

    def lookup_api_spec(doc, options, response)
      doc.response_for(
        options.fetch(:path, response.request.path),
        response.request.request_method.downcase,
        response.status.to_s
      )
    end
  end
end
