RSpec.describe OpenapiContracts::Doc::Request do
  subject(:request) { doc.operation_for(path, method).request_body }

  let(:doc) { OpenapiContracts::Doc.parse(FIXTURES_PATH.join('openapi')) }
  let(:path) { '/user' }
  let(:method) { 'post' }

  context 'when there is no request_body defined on the operation' do
    let(:method) { 'get' }

    it { is_expected.to be_nil }
  end

  describe '#supports_media_type?' do
    subject { request.supports_media_type?(media_type) }

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
    subject { request.schema_for(media_type) }

    context 'when media_type is supported' do
      let(:media_type) { 'application/json' }

      it { is_expected.to be_a(OpenapiContracts::Doc::Schema) }
    end

    context 'when media_type is not supported' do
      let(:media_type) { 'application/text' }

      it { is_expected.to be_nil }
    end
  end
end
