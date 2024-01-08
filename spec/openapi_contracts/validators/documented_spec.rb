RSpec.describe OpenapiContracts::Validators::Documented do
  subject { described_class.new(stack, env) }

  let(:env) do
    OpenapiContracts::Env.new(operation:, response:, request: response.request)
  end
  let(:operation) { doc.operation_for(path, method) }
  let(:stack) { ->(errors) { errors } }

  include_context 'when using GET /user'

  context 'when the operation is not documented' do
    let(:path) { '/unknown' }

    it 'returns an error' do
      expect(subject.call).to eq ['Undocumented operation for "GET /unknown"']
    end
  end

  context 'when the response status is not documented' do
    let(:response_status) { '204' }

    it 'returns an error' do
      expect(subject.call).to eq ['Undocumented response for "GET /user" with http status No Content (204)']
    end
  end
end
