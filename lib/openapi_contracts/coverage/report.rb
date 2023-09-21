class OpenapiContracts::Coverage
  class Report
    def self.merge(doc, *reports)
      reports.each_with_object(Report.new(doc)) do |r, m|
        m.merge!(r)
      end
    end

    attr_reader :data

    def as_json(*)
      report
    end

    def initialize(doc, data = {})
      @doc = doc
      @data = data
    end

    def generate(pathname)
      File.write(pathname, JSON.pretty_generate(report))
    end

    def merge!(data)
      @data.deep_merge!(data) { |_key, val1, val2| val1 + val2 }
    end

    def meta
      {
        'operations' => {
          'covered' => total_covered_operations,
          'total'   => @doc.operations.count
        },
        'responses'  => {
          'covered' => total_covered_responses,
          'total'   => @doc.responses.count
        }
      }.tap do |d|
        d['operations']['quota'] = d['operations']['covered'].to_f / d['operations']['total']
        d['responses']['quota'] = d['responses']['covered'].to_f / d['responses']['total']
      end
    end

    private

    def report
      {
        'meta'  => meta,
        'paths' => @data
      }
    end

    def total_covered_operations
      @doc.operations.select { |o| @data.dig(o.path.to_s, o.verb).present? }.count
    end

    def total_covered_responses
      @doc.responses.select { |r|
        @data.dig(r.operation.path.to_s, r.operation.verb, r.status).present?
      }.count
    end
  end
end
