module OpenapiContracts
  class Doc
    autoload :Header,     'openapi_contracts/doc/header'
    autoload :FileParser, 'openapi_contracts/doc/file_parser'
    autoload :Method,     'openapi_contracts/doc/method'
    autoload :Parser,     'openapi_contracts/doc/parser'
    autoload :Path,       'openapi_contracts/doc/path'
    autoload :Response,   'openapi_contracts/doc/response'
    autoload :Schema,     'openapi_contracts/doc/schema'

    def self.parse(dir, filename = 'openapi.yaml')
      new Parser.call(dir, filename)
    end

    attr_reader :schema

    def initialize(schema)
      @schema = Schema.new(schema)
      @paths = @schema['paths'].to_h do |path, _|
        [path, Path.new(path, @schema.at_pointer(['paths', path]))]
      end
      @dynamic_paths = paths.select(&:dynamic?)
    end

    # Returns an Enumerator over all paths
    def paths
      @paths.each_value
    end

    def response_for(path, method, status)
      with_path(path)&.with_method(method)&.with_status(status)
    end

    # Returns an Enumerator over all Responses
    def responses(&block)
      return enum_for(:responses) unless block_given?

      paths.each do |path|
        path.methods.each do |method|
          method.responses.each(&block)
        end
      end
    end

    def with_path(path)
      if @paths.key?(path)
        @paths[path]
      else
        @dynamic_paths.find { |p| p.matches?(path) }
      end
    end
  end
end
