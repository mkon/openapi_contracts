module OpenapiContracts
  class Doc::Parser
    def self.call(dir)
      new(dir).parse('openapi.yaml')
    end

    def initialize(dir)
      @dir = dir
    end

    def parse(path = 'openapi.yaml')
      abs_path = @dir.join(path)
      data = parse_file(abs_path, translate: false)
      data.deep_merge! merge_components
      data = join_partials(abs_path.dirname, data)
      data
    end

    private

    def parse_file(path, translate: true)
      schema = YAML.safe_load(File.read(path))
      translate ? translate_paths(schema, Pathname(path).parent) : schema
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

    def merge_components
      data = {}
      Dir[File.expand_path("components/**/*.yaml", @dir)].each do |file|
        # pn = Pathname(file).relative_path_from(@dir)
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

    def translate_paths(data, cwd)
      data.each_with_object({}) do |(key, val), m|
        if val.is_a?(Hash)
          m[key] = translate_paths(val, cwd)
        elsif key == '$ref' && val !~ /^#\//
          m[key] = json_pointer(cwd.join(val), '#/')
        else
          m[key] = val
        end
      end
    end

    def json_pointer(pathname, prefix = '')
      relative = pathname.relative_path_from(@dir)
      "#{prefix}#{relative.to_s.delete_suffix(pathname.extname)}"
    end
  end
end
