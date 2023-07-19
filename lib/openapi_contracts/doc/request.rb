module OpenapiContracts
  class Doc::Request
    def initialize(schema)
      @schema = schema.follow_refs
    end

    def schema_for(content_type)
      return unless supports_content_type?(content_type)

      @schema.navigate('content', content_type, 'schema')
    end

    def supports_content_type?(content_type)
      @schema.dig('content', content_type).present?
    end
  end
end
