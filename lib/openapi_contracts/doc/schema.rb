module OpenapiContracts
  # Represents a part or the whole schema
  # Generally even parts of the schema contain the whole schema, but store the pointer to
  # their position in the overall schema. This allows even small sub-schemas to resolve
  # links to any other part of the schema
  class Doc::Schema
    attr_reader :pointer, :raw

    def initialize(raw, pointer = nil)
      @raw = raw
      @pointer = pointer.freeze
    end

    # Resolves Schema ref pointers links like "$ref: #/some/path" and returns new sub-schema
    # at the target if the current schema is only a ref link.
    def follow_refs
      if (ref = as_h['$ref'])
        at_pointer(ref.split('/')[1..])
      else
        self
      end
    end

    # Generates a fragment pointer for the current schema path
    def fragment
      pointer.map { |p| p.gsub('/', '~1') }.join('/').then { |s| "#/#{s}" }
    end

    delegate :dig, :fetch, :keys, :key?, :[], :to_h, to: :as_h

    def at_pointer(pointer)
      self.class.new(raw, pointer)
    end

    def as_h
      return @raw if pointer.nil? || pointer.empty?

      @raw.dig(*pointer)
    end

    def navigate(*spointer)
      self.class.new(@raw, (pointer + Array.wrap(spointer)))
    end
  end
end
