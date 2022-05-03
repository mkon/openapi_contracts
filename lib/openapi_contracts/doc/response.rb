module OpenapiContracts
  class Doc::Response
    def initialize(schema)
      @schema = schema
    end

    def headers
      return @headers if instance_variable_defined? :@headers

      @headers = @schema.fetch('headers', {}).map do |(key, val)|
        Doc::Header.new(key, val)
      end
    end

    def schema_for(content_type)
      return unless supports_content_type?(content_type)

      @schema.navigate('content', content_type, 'schema')
    end

    def no_content?
      !@schema.key? 'content'
    end

    def supports_content_type?(content_type)
      @schema.dig('content', content_type).present?
    end
  end
end
