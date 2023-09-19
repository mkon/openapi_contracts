RSpec.describe OpenapiContracts::Match do
  subject do
    described_class.new(doc, response)
  end

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
end
