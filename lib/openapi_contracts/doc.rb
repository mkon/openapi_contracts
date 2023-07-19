module OpenapiContracts
  class Doc
    autoload :Header,         'openapi_contracts/doc/header'
    autoload :FileParser,     'openapi_contracts/doc/file_parser'
    autoload :Operation,      'openapi_contracts/doc/operation'
    autoload :Parser,         'openapi_contracts/doc/parser'
    autoload :Parameter,      'openapi_contracts/doc/parameter'
    autoload :Path,           'openapi_contracts/doc/path'
    autoload :Request,        'openapi_contracts/doc/request'
    autoload :Response,       'openapi_contracts/doc/response'
    autoload :Schema,         'openapi_contracts/doc/schema'
    autoload :WithParameters, 'openapi_contracts/doc/with_parameters'

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

    def operation_for(path, method)
      OperationRouter.new(self).route(path, method.downcase)
    end

    # Returns an Enumerator over all Responses
    def responses(&block)
      return enum_for(:responses) unless block_given?

      paths.each do |path|
        path.operations.each do |operation|
          operation.responses.each(&block)
        end
      end
    end

    def with_path(path)
      @paths[path]
    end
  end
end
