module OpenapiContracts
  class Coverage
    autoload :Report, 'openapi_contracts/coverage/report'
    autoload :Store,  'openapi_contracts/coverage/store'

    def self.merge_reports(doc, *others)
      reports = others.map { |fp| JSON(File.read(fp))['paths'] }
      Report.merge(doc, *reports)
    end

    attr_reader :store

    def initialize(doc)
      @store = Store.new
      @doc = doc
    end

    delegate :clear!, :data, :increment!, to: :store

    def report
      Report.new(@doc, store.data)
    end
  end
end
