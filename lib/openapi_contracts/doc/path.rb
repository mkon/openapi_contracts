module OpenapiContracts
  class Doc::Path
    include Doc::WithParameters

    HTTP_METHODS = %w(get head post put delete connect options trace patch).freeze

    attr_reader :path

    def initialize(path, spec)
      @path = path
      @spec = spec
      @supported_methods = HTTP_METHODS & @spec.keys
      @operations = @supported_methods.to_h do |verb|
        [verb, Doc::Operation.new(self, @spec.navigate(verb))]
      end
    end

    def dynamic?
      @path.include?('{')
    end

    def operations
      @operations.each_value
    end

    def path_regexp
      @path_regexp ||= begin
        re = /\{([^\}]+)\}/
        @path.gsub(re) { |placeholder|
          placeholder.match(re) { |m| "(?<#{m[1]}>[^/]*)" }
        }.then { |str| Regexp.new("^#{str}$") }
      end
    end

    def static?
      !dynamic?
    end

    def supports_method?(method)
      @operations.key?(method)
    end

    def to_s
      @path
    end

    def with_method(method)
      @operations[method]
    end
  end
end
