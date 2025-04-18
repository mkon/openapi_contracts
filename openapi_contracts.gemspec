$LOAD_PATH.push File.expand_path('lib', __dir__)

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'openapi_contracts'
  s.version     = ENV.fetch 'VERSION', '0.14.0'
  s.authors     = ['mkon']
  s.email       = ['konstantin@munteanu.de']
  s.homepage    = 'https://github.com/mkon/openapi_contracts'
  s.summary     = 'Openapi schemas as API contracts'
  s.license     = 'MIT'
  s.required_ruby_version = '>= 3.2', '< 3.5'

  s.files = Dir['lib/**/*', 'README.md']

  s.add_dependency 'activesupport', '>= 6.1', '< 8.1'
  s.add_dependency 'json_schemer', '>= 2.1', '< 2.4'
  s.add_dependency 'openapi_parameters', '>= 0.3.3', '< 0.4'
  s.add_dependency 'rack', '>= 2.0.0'

  s.add_development_dependency 'json_spec', '~> 1.1.5'
  s.add_development_dependency 'rspec', '~> 3.13.0'
  s.add_development_dependency 'rubocop', '1.64.1'
  s.add_development_dependency 'rubocop-rspec', '2.31.0'
  s.add_development_dependency 'simplecov', '~> 0.22.0'
  s.metadata['rubygems_mfa_required'] = 'true'
end
