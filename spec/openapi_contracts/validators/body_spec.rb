RSpec.describe OpenapiContracts::Validators::Body do
  subject { described_class.new(stack, env) }

  let(:env) { OpenapiContracts::Env.new(spec, response, 200) }
  let(:spec) { doc.response_for(path, method.downcase, response_status.to_s) }
  let(:stack) { ->(errors) { errors } }

  include_context 'when using GET /user' do
    let(:response_json) { {data: user} }
  end

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
