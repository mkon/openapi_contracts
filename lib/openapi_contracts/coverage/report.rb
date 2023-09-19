module OpenapiContracts::Coverage
  class Report
    def self.merge(doc, *reports)
      reports.each_with_object(Report.new(doc)) do |r, m|
        m.merge!(r)
      end
    end

    attr_reader :data

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

    private

    def meta
      {
        'operations' => {
          'covered' => total_covered_operations,
          'total'   => @doc.paths.map { |p| p.operations.count }.reduce(&:+)
        },
        'responses'  => {
          'covered' => total_covered_responses,
          'total'   => @doc.responses.count
        }
      }
    end

    def report
      {
        'meta'  => meta,
        'paths' => @data
      }
    end

    def total_covered_operations
      @doc.paths.map { |p|
        p.operations.select { |o| @data.dig(p.to_s, o.verb).present? }.count
      }.reduce(&:+)
    end

    def total_covered_responses
      @doc.paths.map { |p|
        p.operations.map do |o|
          o.responses.select { |r|
            @data.dig(p.to_s, o.verb, r.status).present?
          }.count
        end
      }.flatten.reduce(&:+)
    end
  end
end
