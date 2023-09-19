module OpenapiContracts::Coverage
  class Report
    def initialize(doc, data)
      @doc = doc
      @data = data
    end

    def generate
      {
        'meta'  => meta,
        'paths' => @data
      }
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
