RSpec.describe 'RSpec integration' do # rubocop:disable RSpec/DescribeClass
  subject { response }

  include_context 'when using GET /user'

  it { is_expected.to match_openapi_doc(doc) }

  it { is_expected.to match_openapi_doc(doc).with_http_status(:ok) }

  it { is_expected.to_not match_openapi_doc(doc).with_http_status(:created) }

  context 'when using component responses' do
    let(:response_status) { 400 }
    let(:response_json) do
      {
        errors: [{}]
      }
    end

    it { is_expected.to match_openapi_doc(doc).with_http_status(:bad_request) }
  end

  context 'when using dynamic paths' do
    let(:path) { '/messages/ef278' }
    let(:response_json) do
      {
        data: {
          id:         '1ef',
          type:       'messages',
          attributes: {
            body: 'foo'
          }
        }
      }
    end

    it { is_expected.to match_openapi_doc(doc, path: '/messages/{id}').with_http_status(:ok) }
  end

  context 'when a required header is missing' do
    before { response_headers.delete('X-Request-Id') }

    it { is_expected.to_not match_openapi_doc(doc) }
  end

  context 'when a required attribute is missing' do
    before { response_json[:data][:attributes].delete(:email) }

    it { is_expected.to_not match_openapi_doc(doc) }
  end

  context 'when an additinal attribute is included' do
    before { response_json[:data][:attributes].merge!(other: 'foo') }

    it { is_expected.to_not match_openapi_doc(doc) }
  end

  context 'when a attribute does not match type' do
    before { response_json[:data][:id] = 1 }

    it { is_expected.to_not match_openapi_doc(doc) }
  end

  context 'when an attribute does match type oneOf' do
    before { response_json[:data][:attributes][:addresses] = {street: 'Somestreet'} }

    it { is_expected.to_not match_openapi_doc(doc) }
  end

  context 'when an attribute does not match type oneOf' do
    before { response_json[:data][:attributes][:addresses] = {foo: 'bar'} }

    it { is_expected.to_not match_openapi_doc(doc) }
  end
end
