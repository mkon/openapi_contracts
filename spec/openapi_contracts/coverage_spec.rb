RSpec.describe OpenapiContracts::Coverage do
  subject { described_class }

  let(:doc) { OpenapiContracts::Doc.parse(openapi_dir) }
  let(:openapi_dir) { FIXTURES_PATH.join('openapi') }

  before { described_class.store.clear! }

  describe '.report' do
    subject { described_class.report(doc) }

    before do
      described_class.store.increment!('/health', 'get', '200', 'text/plain')
      described_class.store.increment!('/user', 'get', '200', 'application/json')
      described_class.store.increment!('/user', 'get', '200', 'application/json')
      described_class.store.increment!('/user', 'get', '401', 'application/json')
      described_class.store.increment!('/user', 'post', '201', 'application/json')
      described_class.store.increment!('/user', 'post', '400', 'application/json')
      described_class.store.increment!('/user', 'post', '400', 'application/json')
    end

    it 'can generate a report' do
      expect(subject.dig('meta', 'operations', 'covered')).to eq(3)
      expect(subject.dig('meta', 'operations', 'total')).to eq(8)
      expect(subject.dig('meta', 'responses', 'covered')).to eq(4)
      expect(subject.dig('meta', 'responses', 'total')).to eq(15)
    end
  end
end
