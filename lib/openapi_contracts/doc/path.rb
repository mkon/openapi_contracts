module OpenapiContracts
  class Doc::Path
    def initialize(schema)
      @schema = schema
      @methods = @schema.to_h do |method, _|
        [method, Doc::Method.new(@schema.navigate(method))]
      end
    end

    def methods
      @methods.each_value
    end

    def with_method(method)
      @methods[method]
    end
  end
end
