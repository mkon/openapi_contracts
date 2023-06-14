module OpenapiContracts
  class Doc::Path
    def initialize(schema)
      @schema = schema

      @methods = (known_http_methods & @schema.keys).to_h do |method|
        [method, Doc::Method.new(@schema.navigate(method))]
      end
    end

    def methods
      @methods.each_value
    end

    def with_method(method)
      @methods[method]
    end

    private

    def known_http_methods
      # https://developer.mozilla.org/en-US/docs/Web/HTTP/Methods
      %w(get head post put delete connect options trace patch).freeze
    end
  end
end
