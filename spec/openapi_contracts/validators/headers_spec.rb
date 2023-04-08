RSpec.describe OpenapiContracts::Validators::Headers do
  subject { described_class.new(stack, env) }

  let(:env) { OpenapiContracts::Env.new(spec, response, 200) }
  let(:spec) { doc.response_for('/user', 'get', '200') }
  let(:stack) { ->(errors) { errors } }

  include_context 'when using GET /user'

  context 'when the headers match the schema' do
    it 'has no errors' do
      expect(subject.call).to be_empty
    end
  end

  context 'when missing a header' do
    before do
      response_headers.delete('X-Request-Id')
    end

    it 'returns the error' do
      expect(subject.call).to eq [
        'Missing header x-request-id'
      ]
    end
  end
end
