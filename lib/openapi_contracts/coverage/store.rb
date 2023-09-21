class OpenapiContracts::Coverage
  class Store
    attr_accessor :data

    def initialize
      @data = {}
    end

    def clear!
      @data = {}
    end

    def increment!(path, method, status, media_type)
      keys = [path, method, status]
      val = @data.dig(*keys) || Hash.new(0).tap { |h| OpenapiContracts.hash_bury!(@data, keys, h) }
      val[media_type] += 1
    end
  end
end
