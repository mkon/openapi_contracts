module OpenapiContracts
  class Doc::Parser
    class Transformer
      def initialize(parser, cwd, pointer)
        @parser = parser
        @cwd = cwd
        @pointer = pointer
      end

      # :nocov:
      def call
        raise NotImplementedError
      end
      # :nocov:
    end

    # OpenApi 3 is a not fully comptible with JSON schema Draft 4
    # This is one of the diffs - draft 4 does not understand nullable
    class NullableTranformer < Transformer
      def call(object)
        return unless object['type'].present? && object['nullable'] == true

        object.delete('nullable')
        object['type'] = [object['type'], 'null']
      end
    end

    class PointerTransformer < Transformer
      def call(object)
        return unless object['$ref'].present?

        object['$ref'] = transform_pointer(object['$ref'])
      end

      private

      def transform_pointer(target)
        if %r{^#/(?<pointer>.*)} =~ target
          # A JSON Pointer
          generate_absolute_pointer(pointer)
        elsif %r{^(?<relpath>[^#]+)(?:#/(?<pointer>.*))?} =~ target
          ptr = @parser.filenesting[@cwd.join(relpath)]
          tgt = ptr.to_json_pointer
          tgt += "/#{pointer}" if pointer
          tgt
        else
          target
        end
      end

      # A JSON pointer to the currently parsed file as seen from the root openapi file
      def generate_absolute_pointer(json_pointer)
        if @pointer.empty?
          "#/#{json_pointer}"
        else
          "#{@pointer.to_json_pointer}/#{json_pointer}"
        end
      end
    end

    TRANSFORMERS = [NullableTranformer, PointerTransformer].freeze

    def self.call(dir, filename)
      new(dir.join(filename)).parse
    end

    attr_reader :filenesting, :rootfile

    def initialize(rootfile)
      @cwd = rootfile.parent
      @rootfile = rootfile
      @filenesting = {}
    end

    def build_file_list
      list = {@rootfile.relative_path_from(@cwd) => Doc::Pointer[]}
      Dir[File.expand_path('components/**/*.yaml', @cwd)].each do |file|
        pathname = Pathname(file).relative_path_from(@cwd)
        pointer = Doc::Pointer.from_path pathname.sub_ext('')
        list.merge! pathname => pointer
      end
      YAML.safe_load_file(@rootfile).fetch('paths') { {} }.each_pair do |k, v|
        next unless v['$ref'] && !v['$ref'].start_with?('#')

        list.merge! Pathname(v['$ref']) => Doc::Pointer['paths', k]
      end
      list
    end

    def parse
      @filenesting = build_file_list
      @filenesting.each_with_object({}) do |(path, pointer), schema|
        target = pointer.to_a.reduce(schema) { |d, k| d[k] ||= {} }
        target.delete('$ref') # ref file pointers must be replaced
        target.merge! file_to_data(path, pointer)
      end
    end

    private

    def file_to_data(pathname, pointer)
      YAML.safe_load_file(@cwd.join(pathname)).tap do |data|
        transform_objects!(data, pathname.parent, pointer)
      end
    end

    def transform_objects!(object, cwd, pointer)
      case object
      when Hash
        object.each_value { |v| transform_objects!(v, cwd, pointer) }
        TRANSFORMERS.map { |t| t.new(self, cwd, pointer) }.each { |t| t.call(object) }
      when Array
        object.each { |o| transform_objects!(o, cwd, pointer) }
      end
    end
  end
end
