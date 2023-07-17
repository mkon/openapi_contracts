RSpec.describe OpenapiContracts::OperationRouter do
  subject(:router) { described_class.new(doc) }

  let(:doc) { OpenapiContracts::Doc.parse(FIXTURES_PATH.join('openapi')) }

  describe '#route(path, method)' do
    subject { router.route(path, method) }

    context 'when routing "GET /messages/acbd1234"' do
      let(:method) { 'get' }
      let(:path) { '/messages/abcd1234' }

      it 'routes correctly' do
        expect(subject).to be_present
        expect(subject).to be_a(OpenapiContracts::Doc::Operation)
      end
    end

    context 'when routing "GET /messages/acbd"' do
      let(:method) { 'get' }
      let(:path) { '/messages/abcd' }

      it { is_expected.to be_nil }
    end

    context 'when routing "GET /user"' do
      let(:method) { 'get' }
      let(:path) { '/user' }

      it 'routes correctly' do
        expect(subject).to be_present
        expect(subject).to be_a(OpenapiContracts::Doc::Operation)
      end
    end

    context 'when routing "DELETE /user"' do
      let(:method) { 'delete' }
      let(:path) { '/user' }

      it { is_expected.to be_nil }
    end

    context 'when routing "GET /unknown"' do
      let(:method) { 'get' }
      let(:path) { '/unknown' }

      it { is_expected.to be_nil }
    end
  end
end
