RSpec.describe OpenapiContracts::Match do
  subject do
    described_class.new(doc, response, options)
  end

  let(:options) { {} }

  before { allow(OpenapiContracts).to receive(:collect_coverage).and_return(true) }
  after { OpenapiContracts::Coverage.store.clear! }

  include_context 'when using GET /user'

  it { is_expected.to be_valid }

  it 'registers the coverage' do
    subject.valid?
    expect(OpenapiContracts::Coverage.store.data).to eq(
      '/user' => {
        'get' => {
          '200' => {
            'application/json' => 1
          }
        }
      }
    )
  end

  context 'when using nocov option' do
    let(:options) { {nocov: true} }

    it 'does not register coverage' do
      subject.valid?
      expect(OpenapiContracts::Coverage.store.data).to eq({})
    end
  end
end
