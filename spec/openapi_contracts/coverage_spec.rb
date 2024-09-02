RSpec.describe OpenapiContracts::Coverage do
  subject(:coverage) { doc.coverage }

  let(:doc) { OpenapiContracts::Doc.parse(openapi_dir) }
  let(:openapi_dir) { FIXTURES_PATH.join('openapi') }

  describe '.merge_reports' do
    subject { described_class.merge_reports(doc, *[file1, file2, file3].map(&:path)) }

    let(:file1) do
      Tempfile.new.tap do |f|
        doc.coverage.clear!
        doc.coverage.increment!('/health', 'get', '200', 'text/plain')
        doc.coverage.increment!('/user', 'get', '200', 'application/json')
        doc.coverage.increment!('/user', 'get', '200', 'application/json')
        doc.coverage.report.generate(f.path)
      end
    end
    let(:file2) do
      Tempfile.new.tap do |f|
        doc.coverage.clear!
        doc.coverage.increment!('/user', 'get', '401', 'application/json')
        doc.coverage.increment!('/user', 'post', '201', 'application/json')
        doc.coverage.report.generate(f.path)
      end
    end
    let(:file3) do
      Tempfile.new.tap do |f|
        doc.coverage.clear!
        doc.coverage.store.increment!('/user', 'post', '400', 'application/json')
        doc.coverage.store.increment!('/user', 'post', '400', 'application/json')
        doc.coverage.report.generate(f.path)
      end
    end

    it 'can generate a report' do
      data = subject.as_json
      expect(data.dig('meta', 'operations', 'covered')).to eq(3)
      expect(data.dig('meta', 'operations', 'total')).to eq(10)
      expect(data.dig('meta', 'responses', 'covered')).to eq(4)
      expect(data.dig('meta', 'responses', 'total')).to eq(17)
    end
  end

  describe '.report' do
    subject { coverage.report }

    before do
      doc.coverage.store.increment!('/health', 'get', '200', 'text/plain')
      doc.coverage.store.increment!('/user', 'get', '200', 'application/json')
      doc.coverage.store.increment!('/user', 'get', '200', 'application/json')
      doc.coverage.store.increment!('/user', 'get', '401', 'application/json')
      doc.coverage.store.increment!('/user', 'post', '201', 'application/json')
      doc.coverage.store.increment!('/user', 'post', '400', 'application/json')
      doc.coverage.store.increment!('/user', 'post', '400', 'application/json')
    end

    it 'can generate a report', :aggregate_failures do
      data = subject.as_json
      expect(data.dig('meta', 'operations', 'covered')).to eq(3)
      expect(data.dig('meta', 'operations', 'total')).to eq(10)
      expect(data.dig('meta', 'responses', 'covered')).to eq(4)
      expect(data.dig('meta', 'responses', 'total')).to eq(17)
    end
  end
end
