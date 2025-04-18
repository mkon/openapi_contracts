RSpec.describe OpenapiContracts::Validators::Headers do
  subject { described_class.new(stack, env) }

  let(:env) { OpenapiContracts::Env.new(operation:, response:) }
  let(:operation) { doc.operation_for(path, method) }
  let(:stack) { ->(errors) { errors } }

  include_context 'when using GET /user'

  context 'when the headers match the schema' do
    it 'has no errors' do
      expect(subject.call).to be_empty
    end
  end

  context 'when header has multiple values' do
    before do
      response_headers['X-Request-Id'] = %w(val1 val2)
    end

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

  context 'when the schema does not match' do
    before do
      response_headers['X-Request-Id'] = 1
    end

    it 'returns the error' do
      expect(subject.call).to eq [
        'Header x-request-id validation error: value at root is not a string (value: 1)'
      ]
    end
  end
end
