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
      data = parse_file(abs_path, translate: false)
      data.deep_merge! merge_components
      data = join_partials(abs_path.dirname, data)
      nullable_to_type!(data)
    end

    private

    def parse_file(path, translate: true)
      schema = YAML.safe_load(File.read(path))
      translate ? translate_paths!(schema, Pathname(path).parent) : schema
    end

    def join_partials(cwd, data)
      data.each_with_object({}) do |(key, val), m|
        if val.is_a?(Hash)
          m[key] = join_partials(cwd, val)
        elsif key == '$ref' && val !~ /^#/
          m.merge! parse_file(cwd.join(val))
        else
          m[key] = val
        end
      end
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

    def merge_components
      data = {}
      Dir[File.expand_path('components/**/*.yaml', @dir)].each do |file|
        pointer = json_pointer(Pathname(file)).split('/')
        i = 0
        pointer.reduce(data) do |h, p|
          i += 1
          if i == pointer.size
            h[p] = parse_file(file)
          else
            h[p] ||= {}
          end
          h[p]
        end
      end
      data
    end

    def translate_paths!(data, cwd)
      case data
      when Array
        data.each { |v| translate_paths!(v, cwd) }
      when Hash
        data.each_pair do |k, v|
          if k == '$ref' && v !~ %r{^#/}
            v.replace json_pointer(cwd.join(v), '#/')
          else
            translate_paths!(v, cwd)
          end
        end
      end
    end

    def json_pointer(pathname, prefix = '')
      relative = pathname.relative_path_from(@dir)
      "#{prefix}#{relative.to_s.delete_suffix(pathname.extname)}"
    end
  end
end
