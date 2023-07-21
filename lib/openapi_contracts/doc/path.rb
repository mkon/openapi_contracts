module OpenapiContracts
  class Doc::Path
    include Doc::WithParameters

    HTTP_METHODS = %w(get head post put delete connect options trace patch).freeze

    attr_reader :path

    def initialize(path, spec)
      @path = path
      @spec = spec
      @supported_methods = HTTP_METHODS & @spec.keys
    end

    def dynamic?
      @path.include?('{')
    end

    def operations
      @supported_methods.each.lazy.map { |m| Doc::Operation.new(self, @spec.navigate(m)) }
    end

    def path_regexp
      @path_regexp ||= begin
        re = /\{(\S+)\}/
        @path.gsub(re) { |placeholder|
          placeholder.match(re) { |m| "(?<#{m[1]}>[^/]*)" }
        }.then { |str| Regexp.new(str) }
      end
    end

    def static?
      !dynamic?
    end

    def supports_method?(method)
      @supported_methods.include?(method)
    end

    def with_method(method)
      return unless supports_method?(method)

      Doc::Operation.new(self, @spec.navigate(method))
    end
  end
end
