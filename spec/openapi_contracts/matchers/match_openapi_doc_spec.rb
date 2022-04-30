RSpec.describe OpenapiContracts::Matchers::MatchOpenapiDoc do
  subject(:matcher) { described_class.new(doc) }

  let(:doc) { OpenapiContracts::Doc.parse(FIXTURES_PATH.join('openapi')) }

  let(:response) { TestResponse.new(last_response, last_request) }
  let(:last_response) { Rack::MockResponse.new(response_status, response_headers, JSON.dump(response_body)) }
  let(:last_request) { Rack::Request.new(request_env) }
  let(:request_env) do
    {
      'PATH_INFO'      => '/user',
      'REQUEST_METHOD' => 'GET',
    }
  end
  let(:response_status) { 200 }
  let(:response_body) do
    {
      data: {
        id: 'some-id',
        type: 'user',
        attributes: {
          email: 'name@me.example',
        }
      }
    }
  end
  let(:response_headers) do
    {
      'Content-Type' => 'application/json',
      'X-Request-Id' => 'random-request-id',
    }
  end

  it 'behaves correctly when matching' do
    expect(matcher.matches?(response)).to be true
    expect(matcher.description).to eq 'to match the openapi schema'
    expect(matcher.failure_message_when_negated).to eq 'request matched the schema'
  end

  context 'when a required header is missing' do
    before { response_headers.delete('X-Request-Id') }

    it 'behaves correctly' do
      expect(matcher.matches?(response)).to be false
      expect(matcher.failure_message).to eq '* Missing header x-request-id'
    end
  end

  context 'when a header does not match' do
    before { response_headers['X-Request-Id'] = 0 }

    it 'behaves correctly' do
      expect(matcher.matches?(response)).to be false
      expect(matcher.failure_message).to start_with '* Header x-request-id does not match'
    end
  end

  context 'when a required attribute is missing' do
    before { response_body[:data][:attributes].delete(:email) }

    it 'behaves correctly' do
      expect(matcher.matches?(response)).to be false
      expect(matcher.failure_message).to start_with "* The property '#/data/attributes' did not contain a required property of 'email' in schema"
    end
  end

  context 'when an additinal attribute is included' do
    before { response_body[:data][:attributes].merge!(other: 'foo') }

    it 'behaves correctly' do
      expect(matcher.matches?(response)).to be false
      expect(matcher.failure_message).to start_with "* The property '#/data/attributes' contains additional properties [\"other\"] outside of the schema when none are allowed in schema"
    end
  end

  context 'when a attribute does not match type' do
    before { response_body[:data][:id] = 1 }

    it 'behaves correctly' do
      expect(matcher.matches?(response)).to be false
      expect(matcher.failure_message).to start_with "* The property '#/data/id' of type integer did not match the following type: string in schema"
    end
  end

  context 'when path is not documented' do
    before { request_env['PATH_INFO'] = '/unknown' }

    it 'behaves correctly' do
      expect(matcher.matches?(response)).to be false
      expect(matcher.failure_message).to eq '* Undocumented request/response for "GET /unknown" with http status OK (200)'
    end
  end

  context 'when status is not documented' do
    let(:response_status) { 204 }

    it 'behaves correctly' do
      expect(matcher.matches?(response)).to be false
      expect(matcher.failure_message).to eq '* Undocumented request/response for "GET /user" with http status No Content (204)'
    end
  end

  context 'when no content should be returned' do
    before { request_env['PATH_INFO'] = '/health' }

    it 'behaves correctly' do
      expect(matcher.matches?(response)).to be false
      expect(matcher.failure_message).to eq '* Expected empty response body'
    end
  end

  context 'when content-type is not documented' do
    before { response_headers['Content-Type'] = 'application/xml' }

    it 'behaves correctly' do
      expect(matcher.matches?(response)).to be false
      expect(matcher.failure_message).to eq '* Undocumented response with content-type "application/xml"'
    end
  end

  context 'when limiting the allowed response status' do
    context 'when setting response status to 200' do
      before { matcher.with_http_status(200) }

      it 'behaves correctly when matching' do
        expect(matcher.matches?(response)).to be true
        expect(matcher.description).to eq 'to match the openapi schema with http status OK (200)'
      end
    end

    context 'when setting response status to :ok' do
      before { matcher.with_http_status(:ok) }

      it 'behaves correctly when matching' do
        expect(matcher.matches?(response)).to be true
        expect(matcher.description).to eq 'to match the openapi schema with http status OK (200)'
      end
    end
  end
end
