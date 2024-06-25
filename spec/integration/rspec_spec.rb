RSpec.describe 'RSpec integration' do
  subject { response }

  include_context 'when using GET /user'

  it { is_expected.to match_openapi_doc(doc) }

  it { is_expected.to match_openapi_doc(doc).with_http_status(:ok) }
  it { is_expected.to match_openapi_doc(doc).with_http_status(200) }

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

  context 'when using polymorphism with discriminators' do
    let(:path) { '/pets' }
    let(:response_status) { 200 }
    let(:response_json) do
      [
        {
          type: 'cat'
        },
        {
          type: 'dog'
        }
      ]
    end

    it { is_expected.to match_openapi_doc(doc).with_http_status(:ok) }

    context 'when encountering unknown types' do
      let(:response_json) do
        [
          {type: 'other'}
        ]
      end

      it { is_expected.to_not match_openapi_doc(doc) }
    end

    context 'when not matching' do
      let(:response_json) do
        [
          {
            type:  'dog',
            leash: 'missing'
          }
        ]
      end

      it { is_expected.to_not match_openapi_doc(doc) }
    end
  end

  context 'when using referenced responses' do
    let(:path) { '/messages/last' }
    let(:response_status) { 400 }
    let(:response_json) do
      {
        errors: [{}]
      }
    end

    it { is_expected.to match_openapi_doc(doc).with_http_status(:bad_request) }
  end

  context 'when using dynamic paths' do
    let(:path) { '/messages/ef278ab2' }
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

    it { is_expected.to match_openapi_doc(doc).with_http_status(:ok) }

    it { is_expected.to match_openapi_doc(doc, path: '/messages/{id}').with_http_status(:ok) }

    context 'when a string attribute is nullable' do
      before { response_json[:data][:attributes][:title] = nil }

      it { is_expected.to match_openapi_doc(doc) }
    end

    context 'when a object attribute is nullable' do
      before { response_json[:data][:attributes][:author] = nil }

      it { is_expected.to match_openapi_doc(doc) }
    end
  end

  context 'when a required header is missing' do
    before { response_headers.delete('X-Request-Id') }

    it { is_expected.to_not match_openapi_doc(doc) }
  end

  context 'when a required attribute is missing' do
    before { response_json[:data][:attributes].delete(:email) }

    it { is_expected.to_not match_openapi_doc(doc) }
  end

  context 'when an additional attribute is included' do
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

  context 'when the response is not documented' do
    let(:method) { 'POST' }

    it { is_expected.to_not match_openapi_doc(doc) }
  end

  context 'when request body is validated' do
    include_context 'when using POST /user'

    it { is_expected.to match_openapi_doc(doc, path: '/user', request_body: true).with_http_status(:created) }

    it { is_expected.to_not match_openapi_doc(doc, path: '/user', request_body: true).with_http_status(:ok) }
  end

  context 'when input parameters are validated' do
    let(:path) { '/pets?order=asc' }
    let(:response_json) do
      [
        {
          type: 'cat'
        },
        {
          type: 'dog'
        }
      ]
    end
    let(:response_status) { 200 }

    it { is_expected.to match_openapi_doc(doc, parameters: true) }

    context 'when input parameters are not valid' do
      let(:path) { '/pets?order=wrong' }

      it { is_expected.to_not match_openapi_doc(doc, parameters: true) }
    end
  end
end
