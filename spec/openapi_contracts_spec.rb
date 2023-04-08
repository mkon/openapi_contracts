RSpec.describe OpenapiContracts do
  include_context 'when using GET /user'

  describe '.match' do
    subject { described_class.match(doc, response) }

    it { is_expected.to be_a(described_class::Match) }

    it { is_expected.to be_valid }

    context 'when the status does not match' do
      subject { described_class.match(doc, response, status: 201) }

      it 'is invalid and exposes all errors' do
        expect(subject).to_not be_valid
        expect(subject.errors).to eq ['Response has http status OK (200)']
      end
    end
  end
end
