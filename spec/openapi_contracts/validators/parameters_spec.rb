require 'active_support/core_ext/object/json'

RSpec.describe OpenapiContracts::Validators::Parameters do
  subject { described_class.new(stack, env) }

  include_context 'when using GET /pets'

  let(:env) { OpenapiContracts::Env.new(operation:, request:, response:) }
  let(:operation) { doc.operation_for('/pets', method) }
  let(:stack) { ->(errors) { errors } }
  let(:doc) do
    OpenapiContracts::Doc.new(
      {
        paths: {
          '/pets': {
            get: {
              parameters: [
                {
                  in:       'query',
                  name:     'order',
                  required:,
                  schema:   {
                    type: 'string',
                    enum: %w(asc desc)
                  }
                }
              ],
              responses:  {
                '200': {
                  description: 'Ok',
                  content:     {
                    'application/json': {}
                  }
                }
              }
            }
          }
        }
      }.as_json
    )
  end

  context 'when optional parameters are missing' do
    let(:path) { '/pets' }
    let(:required) { false }

    it 'has no errors' do
      expect(subject.call).to be_empty
    end
  end

  context 'when required parameters are missing' do
    let(:path) { '/pets' }
    let(:required) { true }

    it 'has errors' do
      expect(subject.call).to contain_exactly 'Missing query parameter "order"'
    end
  end

  context 'when required parameters are present' do
    let(:path) { '/pets?order=asc' }
    let(:required) { true }

    it 'has no errors' do
      expect(subject.call).to be_empty
    end
  end

  context 'when parameters are wrong' do
    let(:path) { '/pets?order=bad' }
    let(:required) { false }

    it 'has errors' do
      expect(subject.call).to contain_exactly '"bad" is not a valid value for the query parameter "order"'
    end
  end
end
