RSpec.describe OpenapiContracts::Doc do
  subject(:doc) { described_class.parse(openapi_dir) }

  let(:openapi_dir) { FIXTURES_PATH.join('openapi') }

  describe '.parse' do
    it { is_expected.to be_a(described_class) }
  end

  describe '#response_for' do
    subject { doc.response_for(path, method, status) }

    let(:path) { '/user' }
    let(:method) { 'get' }
    let(:status) { '200' }

    it { is_expected.to be_a(OpenapiContracts::Response) }
  end
end
