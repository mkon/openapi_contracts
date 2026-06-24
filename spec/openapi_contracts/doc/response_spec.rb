RSpec.describe OpenapiContracts::Doc::Response do
  subject(:response) { doc.operation_for(path, method).response_for_status(status) }

  let(:doc) { OpenapiContracts::Doc.parse(FIXTURES_PATH.join('openapi')) }

  context 'with content-less responses' do
    subject(:response) { doc.operation_for('/health', 'get').response_for_status('200') }

    describe '#no_content?' do
      subject { response.no_content? }

      it { is_expected.to be true }
    end

    describe '#supports_media_type?' do
      subject { response.supports_media_type?('application/json') }

      it { is_expected.to be false }
    end
  end

  context 'with standard responses' do
    subject(:response) { doc.operation_for('/user', 'get').response_for_status('200') }

    describe '#no_content?' do
      subject { response.no_content? }

      it { is_expected.to be false }
    end

    describe '#supports_media_type?' do
      subject { response.supports_media_type?(media_type) }

      context 'when media_type is supported' do
        let(:media_type) { 'application/json' }

        it { is_expected.to be true }
      end

      context 'when media_type is not supported' do
        let(:media_type) { 'application/text' }

        it { is_expected.to be false }
      end
    end

    describe '#schema_for' do
      subject { response.schema_for(media_type) }

      context 'when media_type is supported' do
        let(:media_type) { 'application/json' }

        it { is_expected.to be_a(OpenapiContracts::Doc::Schema) }
      end

      context 'when media_type is not supported' do
        let(:media_type) { 'application/text' }

        it { is_expected.to be_nil }
      end
    end

    describe '#headers' do
      context 'when a header is defined inline' do
        subject(:header) { response.headers.find { |h| h.name == 'x-request-id' } }

        it 'exposes its schema' do
          expect(header.schema).to eq('type' => 'string')
          expect(header.required?).to be true
        end
      end

      context 'when a header is defined via $ref' do
        subject(:header) { response.headers.find { |h| h.name == 'x-trace-id' } }

        it 'follows the ref and exposes the referenced schema' do
          expect(header.schema).to eq('type' => 'string', 'format' => 'uuid')
        end
      end
    end
  end
end
