RSpec.describe OpenapiContracts::Validators::Documented do
  subject { described_class.new(stack, env) }

  let(:env) { OpenapiContracts::Env.new(spec, response, 204, match_request_body?, request_body) }
  let(:spec) { doc.response_for(path, method.downcase, response_status.to_s) }
  let(:request_body) { doc.request_for(path, method.downcase) }
  let(:stack) { ->(errors) { errors } }

  include_context 'when using GET /user'

  context 'when the request body is not documented' do
    let(:match_request_body?) { true }

    it 'returns an error' do
      expect(subject.call).to eq ['Undocumented request body for "GET /user"']
    end
  end

  context 'when the response is not documented' do
    let(:match_request_body?) { false }
    let(:response_status) { 204 }

    it 'returns an error' do
      expect(subject.call).to eq ['Undocumented response for "GET /user" with http status No Content (204)']
    end
  end
end
