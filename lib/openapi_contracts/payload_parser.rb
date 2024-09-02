require 'singleton'

module OpenapiContracts
  class PayloadParser
    include Singleton

    class << self
      delegate :parse, :register, to: :instance
    end

    Entry = Struct.new(:matcher, :parser) do
      def call(raw)
        parser.call(raw)
      end

      def match?(media_type)
        matcher == media_type || matcher.match?(media_type)
      end
    end

    def initialize
      @parsers = []
    end

    def parse(media_type, payload)
      parser = @parsers.find { |e| e.match?(media_type) }
      raise ArgumentError, "#{media_type.inspect} is not supported yet" unless parser

      parser.call(payload)
    end

    def register(matcher, parser)
      @parsers << Entry.new(matcher, parser)
    end
  end

  PayloadParser.register(%r{(/|\+)json$}, ->(raw) { JSON(raw) })
  PayloadParser.register('application/x-www-form-urlencoded', ->(raw) { Rack::Utils.parse_nested_query(raw) })
  PayloadParser.register(%r{^text/}, ->(raw) { raw })
end
