module OpenapiContracts
  class Doc::Header
    attr_reader :name

    def initialize(name, data)
      @name = name
      @data = data
    end

    def required?
      @data['required']
    end

    def schema
      @data['schema']
    end
  end
end
