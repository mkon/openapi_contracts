module OpenapiContracts
  class Doc::Parser
    # OpenApi 3 is a not fully comptible with JSON schema Draft 4
    # This is one of the diffs - draft 4 does not understand nullable
    class NullableTranformer
      def self.call(object)
        return unless object['type'] && object['nullable']

        object['type'] = [object['type'], 'null']
        object.delete 'nullable'
      end
    end

    TRANSFORMERS = [NullableTranformer].freeze

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
      transform_objects!(data)
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

    def transform_objects!(object)
      case object
      when Hash
        TRANSFORMERS.each { |t| t.call(object) }
        object.each_value { |o| transform_objects! o }
      when Array
        object.each { |o| transform_objects! o }
      end
    end
  end
end
