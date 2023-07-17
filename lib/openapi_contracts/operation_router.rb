module OpenapiContracts
  class OperationRouter
    def initialize(doc)
      @doc = doc
      @dynamic_paths = doc.paths.select(&:dynamic?)
    end

    def route(actual_path, method)
      @doc.with_path(actual_path)&.then { |p| return p.with_method(method) }

      @dynamic_paths.each do |path|
        next unless path.supports_method?(method)

        operation = path.with_method(method)
        parameters = (path.parameters + operation.parameters).select(&:in_path?)

        return operation if parameter_match?(path.path_regexp, actual_path, parameters)
      end

      nil
    end

    private

    def parameter_match?(path_regexp, actual_path, parameters)
      path_regexp.match(actual_path) do |m|
        m.named_captures.each do |k, v|
          return false unless parameters&.find { |s| s.name == k }&.matches?(v)
        end
        return true
      end
      false
    end
  end
end
