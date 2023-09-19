require 'active_support'
require 'active_support/core_ext/array'
require 'active_support/core_ext/hash'
require 'active_support/core_ext/class'
require 'active_support/core_ext/module'
require 'active_support/core_ext/string'
require 'rubygems/version'

require 'json_schemer'
require 'rack'
require 'yaml'

module OpenapiContracts
  autoload :Coverage,        'openapi_contracts/coverage'
  autoload :Doc,             'openapi_contracts/doc'
  autoload :Helper,          'openapi_contracts/helper'
  autoload :Match,           'openapi_contracts/match'
  autoload :OperationRouter, 'openapi_contracts/operation_router'
  autoload :Parser,          'openapi_contracts/parser'
  autoload :PayloadParser,   'openapi_contracts/payload_parser'
  autoload :Validators,      'openapi_contracts/validators'

  Env = Struct.new(:operation, :options, :request, :response, keyword_init: true)

  module_function

  def match(doc, response, options = {})
    Match.new(doc, response, options)
  end

  def hash_bury(hash, keys, value)
    other = keys.reverse.reduce(value) { |m, k| {k => m} }
    hash.deep_merge other
  end

  def hash_bury!(hash, keys, value)
    other = keys.reverse.reduce(value) { |m, k| {k => m} }
    hash.deep_merge! other
    other
  end
end

require 'openapi_contracts/rspec' if defined?(RSpec)
