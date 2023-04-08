RSpec.describe OpenapiContracts::Validator do
  subject do
    described_class.new(doc, response)
  end

  include_context 'when using GET /user'

  it { is_expected.to be_valid }
end
