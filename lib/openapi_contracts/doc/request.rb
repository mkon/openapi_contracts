module OpenapiContracts
  class Doc::Request
    def initialize(schema)
      @schema = schema.follow_refs
    end

    def schema_for(media_type)
      return unless supports_media_type?(media_type)

      @schema.navigate('content', media_type, 'schema')
    end

    def supports_media_type?(media_type)
      @schema.dig('content', media_type).present?
    end
  end
end
