class TestResponse < Rack::Response
  # Rack::Response can not access request
  # Make our response behave more like ActionDispatch::Response
  attr_accessor :request
end

class TestRequest < Rack::Request
  def self.build(path, opts = {})
    new Rack::MockRequest.env_for(path, opts)
  end
end
