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

    delegate :empty?, to: :@segments

    def parent
      self.class[to_a[0..-2]]
    end

    def to_a
      @segments
    end

    def to_json_pointer
      @segments.map { |s|
        s.gsub(%r{/}, '~1')
      }.join('/').then { |s| "#/#{s}" }
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
  end
end
