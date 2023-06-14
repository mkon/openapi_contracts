module OpenapiContracts
  class Doc::Parser
    def self.call(dir, filename)
      new(dir.join(filename)).parse
    end

    def initialize(rootfile)
      @rootfile = rootfile
    end

    def parse
      file = Doc::FileParser.parse(@rootfile, @rootfile)
      data = file.data
      data.deep_merge! merge_components
      nullable_to_type!(data)
      # debugger
    end

    private

    def merge_components
      data = {}
      Dir[File.expand_path('components/**/*.yaml', @rootfile.parent)].each do |file|
        result = Doc::FileParser.parse(@rootfile, Pathname(file))
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
