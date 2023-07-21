module OpenapiContracts
  class Doc::Pointer
    def self.[](*segments)
      new Array.wrap(segments).flatten
    end

    def self.from_json_pointer(str)
      raise ArguementError unless %r{^#/(?<pointer>.*)} =~ str

      new(pointer.split('/').map { |s| s.gsub('~1', '/') })
    end

    def self.from_path(pathname)
      new pathname.to_s.split('/')
    end

    def initialize(segments)
      @segments = segments
    end

    def inspect
      "<#{self.class.name}#{to_a}>"
    end

    delegate :empty?, to: :@segments

    def navigate(*segments)
      self.class[to_a + segments]
    end

    def parent
      self.class[to_a[0..-2]]
    end

    def to_a
      @segments
    end

    def to_json_pointer
      escaped_segments.join('/').then { |s| "#/#{s}" }
    end

    def to_json_schemer_pointer
      www_escaped_segments.join('/').then { |s| "#/#{s}" }
    end

    def walk(object)
      return object if empty?

      @segments.inject(object) do |obj, key|
        return nil unless obj

        if obj.is_a?(Array)
          raise ArgumentError unless /^\d+$/ =~ key

          key = key.to_i
        end

        obj[key]
      end
    end

    def ==(other)
      to_a == other.to_a
    end

    private

    def escaped_segments
      @segments.map do |s|
        s.gsub(%r{/}, '~1')
      end
    end

    def www_escaped_segments
      escaped_segments.map do |s|
        URI.encode_www_form_component(s)
      end
    end
  end
end
