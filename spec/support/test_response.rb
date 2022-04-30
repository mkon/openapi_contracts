require 'delegate'

# TODO: Find a better way to work wiht both ActionDispatch and Rack::Test
# Rack::Test can not access request from response
class TestResponse < SimpleDelegator
  attr_reader :request

  def initialize(response, request)
    @request = request
    super response
  end
end
