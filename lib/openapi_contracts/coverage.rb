module OpenapiContracts
  module Coverage
    autoload :Report, 'openapi_contracts/coverage/report'
    autoload :Store,  'openapi_contracts/coverage/store'

    def self.store
      Thread.current[:openapi_contracts_coverage_store] ||= Store.new
    end

    def self.report(doc, filepath)
      Report.new(doc, store.data).generate(filepath)
    end
  end
end
