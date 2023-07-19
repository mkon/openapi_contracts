module OpenapiContracts
  class Doc::Response
    def initialize(schema)
      @schema = schema.follow_refs
    end

    def headers
      return @headers if instance_variable_defined? :@headers

      @headers = @schema.fetch('headers', {}).map do |(key, val)|
        Doc::Header.new(key, val)
      end
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
