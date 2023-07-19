RSpec.describe OpenapiContracts::Doc::Response do
  subject(:response) { doc.operation_for(path, method).response_for_status(status) }

  let(:doc) { OpenapiContracts::Doc.parse(FIXTURES_PATH.join('openapi')) }

  context 'with content-less responses' do
    subject(:response) { doc.operation_for('/health', 'get').response_for_status('200') }

    describe '#no_content?' do
      subject { response.no_content? }

      it { is_expected.to be true }
    end

    describe '#supports_content_type?' do
      subject { response.supports_content_type?('application/json') }

      it { is_expected.to be false }
    end
  end

  context 'with standard responses' do
    subject(:response) { doc.operation_for('/user', 'get').response_for_status('200') }

    describe '#no_content?' do
      subject { response.no_content? }

      it { is_expected.to be false }
    end

    describe '#supports_content_type?' do
      subject { response.supports_content_type?(content_type) }

      context 'when content_type is supported' do
        let(:content_type) { 'application/json' }

        it { is_expected.to be true }
      end

      context 'when content_type is not supported' do
        let(:content_type) { 'application/text' }

        it { is_expected.to be false }
      end
    end

    describe '#schema_for' do
      subject { response.schema_for(content_type) }

      context 'when content_type is supported' do
        let(:content_type) { 'application/json' }

        it { is_expected.to be_a(OpenapiContracts::Doc::Schema) }
      end

      context 'when content_type is not supported' do
        let(:content_type) { 'application/text' }

        it { is_expected.to be_nil }
      end
    end
  end
end
