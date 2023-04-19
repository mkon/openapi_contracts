module OpenapiContracts
  # Represents a part or the whole schema
  # Generally even parts of the schema contain the whole schema, but store the pointer to
  # their position in the overall schema. This allows even small sub-schemas to resolve
  # links to any other part of the schema
  class Doc::Schema
    attr_reader :path, :schema

    def initialize(schema, path = nil)
      @schema = schema
      @path = path.freeze
    end

    # Resolves Schema ref pointers links like "$ref: #/some/path" and returns new sub-schema
    # at the target if the current schema is only a ref link.
    def follow_refs
      if (ref = dig('$ref'))
        at_path(ref.split('/')[1..])
      else
        self
      end
    end

    # Generates a fragment pointer for the current schema path
    def fragment
      path.map { |p| p.gsub('/', '~1') }.join('/').then { |s| "#/#{s}" }
    end

    delegate :dig, :fetch, :key?, :[], to: :to_h

    def at_path(path)
      self.class.new(schema, path)
    end

    def to_h
      return @schema if path.nil? || path.empty?

      @schema.dig(*path)
    end

    def navigate(*sub_path)
      self.class.new(schema, (path + Array.wrap(sub_path)))
    end
  end
end
