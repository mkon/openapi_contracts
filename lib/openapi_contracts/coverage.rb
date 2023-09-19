module OpenapiContracts
  module Coverage
    autoload :Report, 'openapi_contracts/coverage/report'
    autoload :Store,  'openapi_contracts/coverage/store'

    def self.store
      @store ||= Store.new
    end

    def self.report(doc)
      Report.new(doc, store.data).generate
    end
  end
end
