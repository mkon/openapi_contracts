module OpenapiContracts
  class OperationRouter
    def initialize(doc)
      @doc = doc
      @dynamic_paths = doc.paths.select(&:dynamic?)
    end

    def route(actual_path, method)
      @doc.with_path(actual_path)&.then { |p| return p.with_method(method) }

      @dynamic_paths.each do |path|
        debugger
        next unless path.supports_method?(method)
        next unless m = path.path_regexp.match(actual_path)

        operation = path.with_method(method)
        parameters = (path.parameters + operation.parameters).select(&:in_path?)

        return operation if parameter_match?(m.named_captures, parameters)
      end

      nil
    end

    private

    def parameter_match?(actual_params, parameters)
      actual_params.each do |k, v|
        return false unless parameters&.find { |s| s.name == k }&.matches?(v)
      end
      true
    end
  end
end
