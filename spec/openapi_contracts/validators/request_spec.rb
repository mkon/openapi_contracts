RSpec.describe OpenapiContracts::Validators::Request do
  subject { described_class.new(stack, env) }

  let(:env) {
    OpenapiContracts::Env.new(spec: spec, response: response, request: response.request,
                              expected_status: 201, match_request_body?: true, request_body: req)
  }
  let(:spec) { doc.response_for(path, method.downcase, response_status.to_s) }
  let(:req) { doc.request_for(path, method.downcase) }
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
      expect(subject.call).to eq [
        '"a2kfn2" at /data/id does not match the request schema',
        'nil at /data/type does not match the request schema',
        'Missing keys: ["email"] at /data/attributes'
      ]
    end
  end

  context 'when the request body has a different content type' do
    let(:content_type) { 'application/xml' }

    it 'returns an error' do
      expect(subject.call).to eq ['Undocumented request with content-type "application/xml"']
    end
  end

  context 'when the request body should exist but does not' do
    let(:path) { '/messages' }

    it 'returns an error' do
      expect(subject.call).to eq ['No request body found']
    end
  end
end
