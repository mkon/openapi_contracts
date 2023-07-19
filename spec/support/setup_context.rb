RSpec.shared_context 'when using GET /user' do
  let(:response) do
    TestResponse[response_status, response_headers, response_body].tap do |resp|
      resp.request = TestRequest.build(path, method: method)
    end
  end
  let(:doc) { OpenapiContracts::Doc.parse(FIXTURES_PATH.join('openapi')) }
  let(:method) { 'GET' }
  let(:path) { '/user' }
  let(:response_body) { JSON.dump(response_json) }
  let(:response_headers) do
    {
      'Content-Type' => 'application/json',
      'X-Request-Id' => 'some-request-id'
    }
  end
  let(:response_json) do
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
  let(:response_status) { 200 }
end

RSpec.shared_context 'when using POST /user' do
  let(:response) do
    TestResponse[response_status, response_headers, response_body].tap do |resp|
      resp.request = TestRequest.build(path, method: method, input: request_body)
      resp.request.set_header('CONTENT_TYPE', content_type)
    end
  end
  let(:doc) { OpenapiContracts::Doc.parse(FIXTURES_PATH.join('openapi')) }
  let(:method) { 'POST' }
  let(:path) { '/user' }
  let(:content_type) { 'application/json' }
  let(:response_body) { JSON.dump(response_json) }
  let(:request_body) { JSON.dump(request_json) }
  let(:response_headers) do
    {
      'Content-Type' => 'application/json',
      'X-Request-Id' => 'some-request-id'
    }
  end
  let(:request_json) do
    {
      data: {
        type:       'user',
        attributes: {
          name:  'john',
          email: 'name@me.example'
        }
      }
    }
  end
  let(:response_json) do
    {
      data: {
        id:         'some-id',
        type:       'user',
        attributes: {
          name:  'john',
          email: 'name@me.example'
        }
      }
    }
  end
  let(:response_status) { 201 }
end
