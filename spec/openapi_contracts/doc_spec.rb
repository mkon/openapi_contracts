RSpec.describe OpenapiContracts::Doc do
  subject(:doc) { described_class.parse(openapi_dir) }

  let(:openapi_dir) { FIXTURES_PATH.join('openapi') }

  describe '.parse' do
    subject(:defined_doc) { described_class.parse(openapi_dir, 'other.openapi.yaml') }

    it 'parses default document when not defined' do
      expect(doc).to be_a(described_class)
    end

    it 'parses correct document when defined' do
      expect(defined_doc).to be_a(described_class)
    end
  end

  describe '#operation_for' do
    subject { doc.operation_for(path, method) }

    let(:path) { '/user' }
    let(:method) { 'get' }

    it { is_expected.to be_a(OpenapiContracts::Doc::Operation) }
  end

  describe '#responses' do
    subject { doc.responses }

    it { is_expected.to all be_a(OpenapiContracts::Doc::Response) }

    it { is_expected.to have_attributes(count: 17) }
  end
end
