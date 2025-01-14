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
                },
                {
                  in:       'query',
                  name:     'page',
                  required: false,
                  schema:   {
                    type: 'integer'
                  }
                },
                {
                  in:       'query',
                  name:     'settings',
                  style:    'deepObject',
                  required: false,
                  schema:   {
                    type:       'object',
                    properties: {
                      page: {
                        type: 'integer'
                      }
                    },
                    required:   ['page']
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

  context 'when passing invalid integer parameter' do
    let(:path) { '/pets?page=word' }
    let(:required) { false }

    it 'has errors' do
      expect(subject.call).to contain_exactly '"word" is not a valid value for the query parameter "page"'
    end
  end

  context 'when passing valid objects' do
    let(:path) { '/pets?settings[page]=1' }
    let(:required) { false }

    it 'has no errors' do
      expect(subject.call).to be_empty
    end
  end

  context 'when passing invalid objects' do
    let(:path) { '/pets?settings[page]=one' }
    let(:required) { false }

    it 'has errors' do
      details = {'page' => 'one'}.inspect
      expect(subject.call).to contain_exactly "#{details} is not a valid value for the query parameter \"settings\""
    end
  end

  context 'when passing non-objects as object' do
    let(:path) { '/pets?settings=false' }
    let(:required) { false }

    it 'has errors' do
      expect(subject.call).to contain_exactly '"false" is not a valid value for the query parameter "settings"'
    end
  end
end
