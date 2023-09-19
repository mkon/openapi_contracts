RSpec.describe OpenapiContracts::Coverage do
  subject { described_class }

  let(:doc) { OpenapiContracts::Doc.parse(openapi_dir) }
  let(:openapi_dir) { FIXTURES_PATH.join('openapi') }

  before { described_class.store.clear! }

  describe '.report' do
    let(:file) { Tempfile.new }

    before do
      described_class.store.increment!('/health', 'get', '200', 'text/plain')
      described_class.store.increment!('/user', 'get', '200', 'application/json')
      described_class.store.increment!('/user', 'get', '200', 'application/json')
      described_class.store.increment!('/user', 'get', '401', 'application/json')
      described_class.store.increment!('/user', 'post', '201', 'application/json')
      described_class.store.increment!('/user', 'post', '400', 'application/json')
      described_class.store.increment!('/user', 'post', '400', 'application/json')
      described_class.report(doc, Pathname(file.path))
    end

    it 'can generate a report' do
      data = JSON(File.read(file))
      expect(data.dig('meta', 'operations', 'covered')).to eq(3)
      expect(data.dig('meta', 'operations', 'total')).to eq(8)
      expect(data.dig('meta', 'responses', 'covered')).to eq(4)
      expect(data.dig('meta', 'responses', 'total')).to eq(15)
    end
  end
end
