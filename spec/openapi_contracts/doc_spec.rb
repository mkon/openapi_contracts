RSpec.describe OpenapiContracts::Doc do
  subject(:doc) { described_class.parse(openapi_dir) }

  let(:openapi_dir) { FIXTURES_PATH.join('openapi') }

  describe '.parse' do
    subject(:defined_doc) { described_class.parse(openapi_dir, 'auth.openapi.yaml') }

    it 'parses default document when not defined' do
      expect(doc).to be_a(described_class)
    end

    it 'parses correct document when defined' do
      expect(defined_doc).to be_a(described_class)
    end
  end

  describe '#response_for' do
    subject { doc.response_for(path, method, status) }

    let(:path) { '/user' }
    let(:method) { 'get' }
    let(:status) { '200' }

    it { is_expected.to be_a(OpenapiContracts::Doc::Response) }
  end

  describe '#responses' do
    subject { doc.responses }

    it { is_expected.to all be_a(OpenapiContracts::Doc::Response) }

    it { is_expected.to have_attributes(count: 8) }
  end
end
