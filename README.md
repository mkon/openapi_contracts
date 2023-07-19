# OpenapiContracts

[![Push & PR](https://github.com/mkon/openapi_contracts/actions/workflows/main.yml/badge.svg)](https://github.com/mkon/openapi_contracts/actions/workflows/main.yml)
[![Gem Version](https://badge.fury.io/rb/openapi_contracts.svg)](https://badge.fury.io/rb/openapi_contracts)
[![Depfu](https://badges.depfu.com/badges/8ac57411497df02584bbf59685634e45/overview.svg)](https://depfu.com/github/mkon/openapi_contracts?project_id=35354)

Use OpenAPI documentation as an API contract.

Currently supports OpenAPI documentation in the structure as used by [Redocly](https://github.com/Redocly/create-openapi-repo), but should also work for single file schemas.

Adds RSpec matchers to easily verify that your requests and responses match the OpenAPI documentation.

## Usage

First, parse your API documentation:

```ruby
# This must point to the folder where the OAS file is stored
$doc = OpenapiContracts::Doc.parse(Rails.root.join('spec/fixtures/openapi/api-docs'), '<filename>')
```

In case the `filename` argument is not set, parser will by default search for the file named `openapi.yaml`.

Ideally you do this once in an RSpec `before(:suite)` hook. Then you can use these matchers in your request specs:

```ruby
subject { make_request and response }

let(:make_request) { get '/some/path' }

it { is_expected.to match_openapi_doc($doc) }
```

You can assert a specific http status to make sure the response is of the right status:

```ruby
it { is_expected.to match_openapi_doc($doc).with_http_status(:ok) }

# This is equal to
it 'responds with 200 and matches the doc' do
  expect(subject).to have_http_status(:ok)
  expect(subject).to match_openapi_doc($doc)
end
```

### Options

The `match_openapi_doc($doc)` method allows passing options as a 2nd argument.

* `path` allows overriding the default `request.path` lookup in case it does not find the
  correct response definition in your schema. This is especially important when there are
  dynamic parameters in the path and the matcher fails to resolve the request path to
  an endpoint in the OAS file.

```ruby
it { is_expected.to match_openapi_doc($doc, path: '/messages/{id}').with_http_status(:ok) }
```

* `request_body` can be set to `true` in case the validation of the request body against the OpenAPI _requestBody_ schema is required.

```ruby
it { is_expected.to match_openapi_doc($doc, request_body: true).with_http_status(:created) }
```

Both options can as well be used simultaneously.

### Without RSpec

You can also use the Validator directly:

```ruby
# Let's raise an error if the response does not match
result = OpenapiContracts.match($doc, response, options = {})
raise result.errors.merge("/n") unless result.valid?
```

### How it works

It uses the `request.path`, `request.method`, `status` and `headers` on the test subject
(which must be the response) to find the request and response schemas in the OpenAPI document.
Then it does the following checks:

* The response is documented
* Required headers are present
* Documented headers match the schema (via json_schemer)
* The response body matches the schema (via json_schemer)
* The request body matches the schema (via json_schemer) - if `request_body: true`

## Future plans

* Validate Webmock stubs against the OpenAPI doc
* Generate example payloads from the OpenAPI doc
