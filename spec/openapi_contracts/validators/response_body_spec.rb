RSpec.describe OpenapiContracts::Validators::ResponseBody do
  subject { described_class.new(stack, env) }

  let(:env) { OpenapiContracts::Env.new(operation: operation, response: response) }
  let(:operation) { doc.operation_for(path, method) }
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
          email: 'joe@host.example',
          rank:  1.0
        }
      }
    end

    it 'has no errors' do
      expect(subject.call).to be_empty
    end
  end

  context 'when having nilled fields' do
    let(:user) do
      {
        id:         '123',
        type:       'user',
        attributes: {
          name:      nil,
          email:     'joe@host.example',
          addresses: nil,
          rank:      nil
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
          name: 'Joe',
          rank: 1
        }
      }
    end

    it 'returns all errors' do
      expect(subject.call).to contain_exactly(
        '1 at `/data/attributes/rank` does not match format: float',
        '1 at `/data/id` is not a string',
        '1 at `/data/attributes/rank` is not null',
        'null at `/data/type` is not a string',
        'object at `/data/attributes` is missing required properties: email'
      )
    end
  end

  context 'when the response body has a different content type' do
    before do
      response_headers['Content-Type'] = 'application/xml'
    end

    let(:response_body) { '<xml\>' }

    it 'returns an error' do
      expect(subject.call).to eq ['Undocumented response with content-type "application/xml"']
    end
  end

  context 'when the response should have no content' do
    let(:path) { '/health' }
    let(:response_body) { '' }

    it 'returns no error' do
      expect(subject.call).to eq []
    end
  end

  context 'when the response should have no content but has' do
    let(:path) { '/health' }
    let(:response_body) { 'OK' }

    it 'returns an error' do
      expect(subject.call).to eq ['Expected empty response body']
    end
  end
end
