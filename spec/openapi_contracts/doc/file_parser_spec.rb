RSpec.describe OpenapiContracts::Doc::FileParser do
  subject(:parser) { described_class.new(openapi_dir.join('openapi.yaml'), pathname) }

  let(:openapi_dir) { FIXTURES_PATH.join('openapi') }

  context 'when the file contains json pointers' do
    subject(:result) { parser.call }

    let(:pathname) { openapi_dir.join('components/schemas/Numbers.yaml') }

    describe '#to_mergable_hash' do
      subject { result.to_mergable_hash.to_json }

      it { is_expected.to be_json_eql(<<~JSON) }
        {
          "components": {
            "schemas": {
              "Numbers": {
                "All": {
                  "allOf": [
                    {
                      "$ref": "#/components/schemas/Numbers/One"
                    },
                    {
                      "$ref": "#/components/schemas/Numbers/Two"
                    },
                    {
                      "$ref": "#/components/schemas/Numbers/Three"
                    }
                  ]
                },
                "One": {
                  "properties": {
                    "one": {
                      "type": "string"
                    }
                  },
                  "type": "object"
                },
                "Three": {
                  "properties": {
                    "three": {
                      "type": "string"
                    }
                  },
                  "type": "object"
                },
                "Two": {
                  "properties": {
                    "two": {
                      "type": "string"
                    }
                  },
                  "type": "object"
                }
              }
            }
          }
        }
      JSON
    end
  end

  context 'when the file contains relative file paths' do
    subject(:result) { parser.call }

    let(:pathname) { openapi_dir.join('paths/user.yaml') }

    describe '#to_mergable_hash' do
      subject { result.to_mergable_hash.to_json }

      it { is_expected.to be_json_eql(<<~JSON) }
        {
          "paths": {
            "user": {
              "get": {
                "description": "Get User",
                "operationId": "get_user",
                "responses": {
                  "200": {
                    "content": {
                      "application/json": {
                        "schema": {
                          "additionalProperties": false,
                          "properties": {
                            "data": {
                              "$ref": "#/components/schemas/User"
                            }
                          },
                          "required": [
                            "data"
                          ],
                          "type": "object"
                        }
                      }
                    },
                    "description": "OK",
                    "headers": {
                      "x-request-id": {
                        "required": true,
                        "schema": {
                          "type": "string"
                        }
                      }
                    }
                  },
                  "400": {
                    "$ref": "#/components/responses/BadRequest"
                  }
                },
                "summary": "Get User",
                "tags": [
                  "User"
                ]
              },
              "post": {
                "description": "Create User",
                "operationId": "create_user",
                "requestBody": {
                  "content": {
                    "application/json": {
                      "schema": {
                        "additionalProperties": false,
                        "properties": {
                          "data": {
                            "additionalProperties": false,
                            "properties": {
                              "attributes": {
                                "additionalProperties": false,
                                "properties": {
                                  "email": {
                                    "$ref": "#/components/schemas/Email"
                                  },
                                  "name": {
                                    "nullable": true,
                                    "type": "string"
                                  }
                                },
                                "required": [
                                  "name",
                                  "email"
                                ],
                                "type": "object"
                              },
                              "type": {
                                "type": "string"
                              }
                            },
                            "required": [
                              "type",
                              "attributes"
                            ],
                            "type": "object"
                          }
                        },
                        "required": [
                          "data"
                        ],
                        "type": "object"
                      }
                    }
                  }
                },
                "responses": {
                  "201": {
                    "content": {
                      "application/json": {
                        "schema": {
                          "additionalProperties": false,
                          "properties": {
                            "data": {
                              "$ref": "#/components/schemas/User"
                            }
                          },
                          "required": [
                            "data"
                          ],
                          "type": "object"
                        }
                      }
                    },
                    "description": "Created",
                    "headers": {
                      "x-request-id": {
                        "required": true,
                        "schema": {
                          "type": "string"
                        }
                      }
                    }
                  },
                  "400": {
                    "$ref": "#/components/responses/BadRequest"
                  }
                },
                "summary": "Create User",
                "tags": [
                  "User"
                ]
              }
            }
          }
        }
      JSON
    end
  end

  context 'when the file contains relative file paths with json pointer' do
    subject(:result) { parser.call }

    let(:pathname) { openapi_dir.join('openapi.yaml') }

    describe '#data' do
      subject { result.data.dig(*%w(paths /numbers get responses 200 content application/json)).to_json }

      it { is_expected.to be_json_eql(<<~JSON) }
        {
          "schema": {
            "$ref": "#/components/schemas/Numbers/All"
          }
        }
      JSON
    end
  end
end
