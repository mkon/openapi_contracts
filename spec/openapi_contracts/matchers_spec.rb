RSpec.describe OpenapiContracts::Matchers do
  include described_class

  let(:doc) { OpenapiContracts::Doc.parse(FIXTURES_PATH.join('openapi')) }

  describe '#match_openapi_doc' do
    subject { match_openapi_doc(doc) }

    it { is_expected.to be_a described_class::MatchOpenapiDoc }
  end
end
