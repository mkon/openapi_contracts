$LOAD_PATH.push File.expand_path('lib', __dir__)

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'openapi_contracts'
  s.version     = ENV.fetch 'VERSION', '0.1.0'
  s.authors     = ['mkon']
  s.email       = ['konstantin@munteanu.de']
  s.homepage    = 'https://github.com/mkon/openapi_response_validator'
  s.summary     = 'Openapi schemas as API contracts'
  s.license     = 'MIT'
  s.required_ruby_version = '>= 2.6', '< 4'

  s.files = Dir['lib/**/*', 'README.md']

  s.add_dependency 'activesupport', '>= 5', '< 8'

  s.add_development_dependency 'rspec'
  s.add_development_dependency 'simplecov'
end
