module OpenapiContracts
  class Doc::FileParser
    Result = Struct.new(:data, :path) do
      def to_mergable_hash
        d = data
        path.ascend do |p|
          d = {p.basename.to_s => d}
        end
        d
      end
    end

    def initialize(root, pathname)
      @root = root
      @pathname = pathname.relative? ? root.join(pathname) : pathname
    end

    def call
      schema = YAML.safe_load(File.read(@pathname))
      schema = transform_hash(schema)
      Result.new(schema, @pathname.relative_path_from(@root).sub_ext(''))
    end

    private

    def transform_hash(data)
      data.each_with_object({}) do |(key, val), m|
        if val.is_a?(Array)
          m[key] = transform_array(val)
        elsif val.is_a?(Hash)
          m[key] = transform_hash(val)
        elsif key == '$ref'
          m.merge! transform_pointer(key, val)
        else
          m[key] = val
        end
      end
    end

    def transform_array(data)
      data.each_with_object([]) do |item, m|
        case item
        when Hash
          m.push transform_hash(item)
        when Array
          m.push transform_array(item)
        else
          m.push item
        end
      end
    end

    def transform_pointer(key, target)
      if %r{^#/(?<pointer>.*)} =~ target
        # A JSON Pointer
        {key => "#/#{@pathname.relative_path_from(@root).sub_ext('').join(pointer)}"}
      elsif %r{^(?<relpath>[^#]+)(?:#/(?<pointer>.*))?} =~ target
        if relpath.start_with?('paths') # path description file pointer
          result = self.class.new(@root, Pathname(relpath)).call
          result.data
        else # A file pointer with potential JSON sub-pointer
          tgt = @pathname.parent.relative_path_from(@root).join(relpath).sub_ext('')
          tgt = tgt.join(pointer) if pointer
          {key => "#/#{tgt}"}
        end
      else
        {key => target}
      end
    end
  end
end
