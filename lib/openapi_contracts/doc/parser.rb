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
      yaml = File.read(abs_path)
      data = YAML.safe_load(yaml)
      join_components(abs_path.dirname, data)
    end

    private

    def join_components(current_path, data)
      data.each_with_object({}) do |(key, val), m|
        if val.is_a?(Hash)
          m[key] = join_components(current_path, val)
        elsif key == '$ref'
          m.merge! parse(current_path.join(val))
        else
          m[key] = val
        end
      end
    end
  end
end
