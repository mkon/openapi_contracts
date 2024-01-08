RSpec.describe OpenapiContracts::Validators::RequestBody do
  subject { described_class.new(stack, env) }

  let(:env) do
    OpenapiContracts::Env.new(operation:, response:, request: response.request)
  end
  let(:operation) { doc.operation_for(path, method) }
  let(:stack) { ->(errors) { errors } }

  include_context 'when using POST /user'

  context 'when the request body matches the schema' do
    it 'has no errors' do
      expect(subject.call).to be_empty
    end
  end

  context 'when having multiple errors' do
    let(:request_json) do
      {
        data: {
          id:         'a2kfn2',
          type:       nil,
          attributes: {
            name: 'Joe'
          }
        }
      }
    end

    it 'returns all errors' do
      expect(subject.call).to contain_exactly(
        'object property at `/data/id` is not defined and schema does not allow additional properties',
        'null at `/data/type` is not a string',
        'object at `/data/attributes` is missing required properties: email'
      )
    end
  end

  context 'when the request body has a different content type' do
    let(:content_type) { 'application/xml' }

    it 'returns an error' do
      expect(subject.call).to eq ['Undocumented request with media-type "application/xml"']
    end
  end
end
