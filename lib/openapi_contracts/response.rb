module OpenapiContracts
  class Response
    def initialize(data)
      @data = data
    end

    def headers
      return @headers if instance_variable_defined? :@headers

      @headers = @data.fetch('headers', {}).map do |(k, v)|
        Header.new(k, v)
      end
    end

    def schema_for(content_type)
      @data.dig('content', content_type, 'schema')
    end

    def no_content?
      !@data.key? 'content'
    end

    def supports_content_type?(content_type)
      @data.dig('content', content_type).present?
    end
  end
end
