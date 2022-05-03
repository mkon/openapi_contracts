$LOAD_PATH.push File.expand_path('lib', __dir__)

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'openapi_contracts'
  s.version     = ENV.fetch 'VERSION', '0.1.0'
  s.authors     = ['mkon']
  s.email       = ['konstantin@munteanu.de']
  s.homepage    = 'https://github.com/mkon/openapi_contracts'
  s.summary     = 'Openapi schemas as API contracts'
  s.license     = 'MIT'
  s.required_ruby_version = '>= 2.6', '< 4'

  s.files = Dir['lib/**/*', 'README.md']

  s.add_dependency 'activesupport', '>= 6.1', '< 8'
  s.add_dependency 'json-schema', '~> 2.8.1'

  s.add_development_dependency 'rack', '~> 2.2.3'
  s.add_development_dependency 'rspec', '~> 3.11.0'
  s.add_development_dependency 'simplecov', '~> 0.21.2'
end
