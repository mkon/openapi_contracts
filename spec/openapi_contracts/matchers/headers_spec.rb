RSpec.describe OpenapiContracts::Matchers::Headers do
  include TestHelper

  subject { described_class.new(stack, env) }

  let(:stack) { ->(errors) { errors } }
  let(:env) { OpenapiContracts::Env.new(spec, response, 200) }
  let(:doc) { OpenapiContracts::Doc.parse(FIXTURES_PATH.join('openapi')) }
  let(:spec) { doc.response_for('/user', 'get', '200') }
  let(:response) { json_response(200, {}).for_request(:get, '/user') }

  context 'when the headers match the schema' do
    it 'has no errors' do
      expect(subject.call).to be_empty
    end
  end

  context 'when missing a header' do
    let(:response) do
      json_response(200, {})
        .tap { |b| b.headers.delete('X-Request-Id') }
        .for_request(:get, '/user')
    end

    it 'returns the error' do
      expect(subject.call).to eq [
        'Missing header x-request-id'
      ]
    end
  end
end
