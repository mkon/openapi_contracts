require 'delegate'

RSpec.describe 'RSpec integration' do # rubocop:disable RSpec/DescribeClass
  subject { TestResponse.new(last_response, last_request) }

  let(:last_response) { Rack::MockResponse.new(response_status, response_headers, JSON.dump(response_body)) }
  let(:response_status) { 200 }
  let(:last_request) { Rack::Request.new(request_env) }

  let(:request_env) do
    {
      'PATH_INFO'      => '/user',
      'REQUEST_METHOD' => 'GET'
    }
  end
  let(:response_body) do
    {
      data: {
        id:         'some-id',
        type:       'user',
        attributes: {
          name:  nil,
          email: 'name@me.example'
        }
      }
    }
  end
  let(:response_headers) do
    {
      'Content-Type' => 'application/json',
      'X-Request-Id' => 'random-request-id'
    }
  end

  let(:doc) { OpenapiContracts::Doc.parse(FIXTURES_PATH.join('openapi')) }

  it { is_expected.to match_openapi_doc(doc) }

  it { is_expected.to match_openapi_doc(doc).with_http_status(:ok) }

  it { is_expected.to_not match_openapi_doc(doc).with_http_status(:created) }

  context 'when using component responses' do
    let(:response_status) { 400 }
    let(:response_body) do
      {
        errors: [{}]
      }
    end

    it { is_expected.to match_openapi_doc(doc).with_http_status(:bad_request) }
  end

  context 'when using dynamic paths' do
    let(:request_env) do
      {
        'PATH_INFO'      => '/messages/ef278',
        'REQUEST_METHOD' => 'GET'
      }
    end
    let(:response_status) { 200 }
    let(:response_body) do
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
    before { response_body[:data][:attributes].delete(:email) }

    it { is_expected.to_not match_openapi_doc(doc) }
  end

  context 'when an additinal attribute is included' do
    before { response_body[:data][:attributes].merge!(other: 'foo') }

    it { is_expected.to_not match_openapi_doc(doc) }
  end

  context 'when a attribute does not match type' do
    before { response_body[:data][:id] = 1 }

    it { is_expected.to_not match_openapi_doc(doc) }
  end

  context 'when an attribute does match type oneOf' do
    before { response_body[:data][:attributes][:addresses] = {street: 'Somestreet'} }

    it { is_expected.to_not match_openapi_doc(doc) }
  end

  context 'when an attribute does not match type oneOf' do
    before { response_body[:data][:attributes][:addresses] = {foo: 'bar'} }

    it { is_expected.to_not match_openapi_doc(doc) }
  end
end
