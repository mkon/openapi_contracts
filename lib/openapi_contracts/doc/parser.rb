module OpenapiContracts
  class Doc::Parser
    def self.call(dir, filename)
      new(dir).parse(filename)
    end

    def initialize(dir)
      @dir = dir
    end

    def parse(path)
      abs_path = @dir.join(path)
      file = Doc::FileParser.parse(@dir, abs_path)
      data = file.data
      data.deep_merge! merge_components
      nullable_to_type!(data)
    end

    private

    def merge_components
      data = {}
      Dir[File.expand_path('components/**/*.yaml', @dir)].each do |file|
        result = Doc::FileParser.parse(@dir, Pathname(file))
        data.deep_merge!(result.to_mergable_hash)
      end
      data
    end

    def nullable_to_type!(object)
      case object
      when Hash
        if object['type'] && object['nullable']
          object['type'] = [object['type'], 'null']
          object.delete 'nullable'
        else
          object.each_value { |o| nullable_to_type! o }
        end
      when Array
        object.each { |o| nullable_to_type! o }
      end
    end
  end
end
