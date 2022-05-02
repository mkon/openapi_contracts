# OpenapiContracts

Use openapi documentation as an api contract.

Currently supports OpenAPI documentation in the structure as used by [Redocly](https://github.com/Redocly/create-openapi-repo), but should also work for single file schemas.

Adds RSpec matchers to easily verify that your responses match the OpenAPI documentation.

## Usage

First parse your api documentation:

```ruby
# This must point to the folder where the "openapi.yaml" file is
$doc = OpenapiContracts::Doc.parse(Rails.root.join('spec', 'fixtures', 'openapi', 'api-docs', 'openapi'))
```

Ideally you do this once in a RSpec `before(:suite)` hook.

Then you can use these matchers in your request specs:

```ruby
subject { make_request and response }

let(:make_request) { get '/some/path' }

it { is_expected.to match_openapi_doc($doc) }
```

You can assert a specific http status to make sure the response is of the right status:

```ruby
it { is_expected.to match_openapi_doc($api_doc).with_http_status(:ok) }

# this is equal to
it 'responds with 200 and matches the doc' do
  expect(subject).to have_http_status(:ok)
  expect(subject).to match_openapi_doc($api_doc)
}
```

### How it works

It uses the `request.path`, `request.method`, `status` and `headers` on the test subject (which must be the response) to find the response schema in the OpenAPI document. Then it does the following checks:

* The response is documented
* Required headers are present
* Documented headers match the schema (via json-schema)
* The response body matches the schema (via json-schema)

## Future plans

* Validate sent requests against the request schema
* Validate Webmock stubs against the OpenAPI doc
* Generate example payloads from the OpenAPI doc
