RSpec.describe OpenapiContracts::Doc::Schema do
  subject(:schema) { doc.schema }

  let(:doc) { OpenapiContracts::Doc.parse(FIXTURES_PATH.join('openapi')) }

  describe '#each' do
    it 'can enumerate the contents' do
      expect(schema.navigate('paths', '/messages/last', 'get', 'responses').each.size).to eq(2)
    end
  end
end
