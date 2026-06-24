module OpenapiContracts
  class Doc::Response
    attr_reader :coverage, :schema, :status, :operation

    delegate :pointer, to: :schema

    def initialize(operation, status, schema)
      @operation = operation
      @status = status
      @schema = schema.follow_refs
    end

    def headers
      @headers ||= Array.wrap(
        @schema.navigate('headers')&.each&.map { |key, schema| Doc::Header.new(key, schema.to_h) }
      )
    end

    def schema_for(media_type)
      return unless supports_media_type?(media_type)

      @schema.navigate('content', media_type, 'schema')
    end

    def no_content?
      !@schema.key? 'content'
    end

    def supports_media_type?(media_type)
      @schema.dig('content', media_type).present?
    end
  end
end
