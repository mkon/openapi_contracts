RSpec.describe OpenapiContracts::Doc do
  subject(:doc) { described_class.parse(openapi_dir) }

  let(:openapi_dir) { FIXTURES_PATH.join('openapi') }

  describe '.parse' do
    it { is_expected.to be_a(described_class) }
  end

  describe '#at_path' do
    subject { doc.at_path(pointer) }

    let(:pointer) { %w(components schemas User) }

    it 'is a correctly initialized schema' do
      expect(subject).to be_a(OpenapiContracts::Doc::Schema)
      hash = subject.to_h
      expect(hash).to be_a(Hash)
      expect(hash['type']).to eq 'object'
      expect(hash.dig('properties', 'attributes', 'required')).to eq %w(email)
    end
  end

  describe '#response_for' do
    subject { doc.response_for(path, method, status) }

    let(:path) { '/user' }
    let(:method) { 'get' }
    let(:status) { '200' }

    it { is_expected.to be_a(OpenapiContracts::Doc::Response) }
  end
end
