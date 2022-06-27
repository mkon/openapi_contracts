module OpenapiContracts
  class Doc::Schema
    attr_reader :path, :schema

    def initialize(schema, path = nil)
      @schema = schema
      @path = path.freeze
    end

    def follow_refs
      if (ref = dig('$ref'))
        at_path(ref.split('/')[1..])
      else
        self
      end
    end

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
