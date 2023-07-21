module OpenapiContracts
  # Represents a part or the whole schema
  # Generally even parts of the schema contain the whole schema, but store the pointer to
  # their position in the overall schema. This allows even small sub-schemas to resolve
  # links to any other part of the schema
  class Doc::Schema
    attr_reader :pointer, :raw

    def initialize(raw, pointer = Doc::Pointer[])
      raise ArgumentError unless pointer.is_a?(Doc::Pointer)

      @raw = raw
      @pointer = pointer.freeze
    end

    def each # rubocop:disable Metrics/MethodLength
      data = resolve
      case data
      when Array
        enum = data.each_with_index
        Enumerator.new(enum.size) do |yielder|
          loop do
            _item, index = enum.next
            yielder << navigate(index.to_s)
          end
        end
      when Hash
        enum = data.each_key
        Enumerator.new(enum.size) do |yielder|
          loop do
            key = enum.next
            yielder << [key, navigate(key)]
          end
        end
      end
    end

    # :nocov:
    def inspect
      "<#{self.class.name} @pointer=#{@pointer.inspect}>"
    end
    # :nocov:

    # Resolves Schema ref pointers links like "$ref: #/some/path" and returns new sub-schema
    # at the target if the current schema is only a ref link.
    def follow_refs
      data = resolve
      if data.is_a?(Hash) && data.key?('$ref')
        at_pointer Doc::Pointer.from_json_pointer(data['$ref'])
      else
        self
      end
    end

    # Generates a fragment pointer for the current schema path
    def fragment
      pointer.to_json_schemer_pointer
    end

    delegate :dig, :fetch, :keys, :key?, :[], :to_h, to: :resolve

    def at_pointer(pointer)
      self.class.new(raw, pointer)
    end

    # Returns the actual sub-specification contents at the pointer of this Specification
    def resolve
      @pointer.walk(@raw)
    end

    def navigate(*segments)
      self.class.new(@raw, pointer.navigate(segments)).follow_refs
    end
  end
end
