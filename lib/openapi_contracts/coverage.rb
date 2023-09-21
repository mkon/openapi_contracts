module OpenapiContracts
  module Coverage
    autoload :Report, 'openapi_contracts/coverage/report'
    autoload :Store,  'openapi_contracts/coverage/store'

    def self.store
      Thread.current[:openapi_contracts_coverage_store] ||= Store.new
    end

    def self.report(doc)
      Report.new(doc, store.data)
    end

    def self.merge_reports(doc, *others)
      reports = others.map { |fp| JSON(File.read(fp))['paths'] }
      Report.merge(doc, *reports)
    end
  end
end
