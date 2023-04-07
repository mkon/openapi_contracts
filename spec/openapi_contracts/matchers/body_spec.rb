RSpec.describe OpenapiContracts::Matchers::Body do
  include TestHelper

  subject { described_class.new(stack, env) }

  let(:stack) { ->(errors) { errors } }
  let(:env) { OpenapiContracts::Env.new(spec, response, 200) }
  let(:doc) { OpenapiContracts::Doc.parse(FIXTURES_PATH.join('openapi')) }
  let(:spec) { doc.response_for('/user', 'get', '200') }
  let(:response) { json_response(200, {data: user}).for_request(:get, '/user') }

  context 'when the body matches the schema' do
    let(:user) do
      {
        id:         '123',
        type:       'user',
        attributes: {
          name:  'Joe',
          email: 'joe@host.example'
        }
      }
    end

    it 'has no errors' do
      expect(subject.call).to be_empty
    end
  end

  context 'when having multiple errors' do
    let(:user) do
      {
        id:         1,
        type:       nil,
        attributes: {
          name: 'Joe'
        }
      }
    end

    it 'returns all errors' do
      expect(subject.call).to eq [
        '1 at /data/id does not match the schema',
        'nil at /data/type does not match the schema',
        'Missing keys: ["email"] at /data/attributes'
      ]
    end
  end
end
