if ENV['COVERAGE']
  require 'simplecov'
  SimpleCov.start do
    add_filter '/spec'
  end
  SimpleCov.minimum_coverage 99
end

require 'rubygems'
require 'bundler'
Bundler.require :default, 'test'

require 'json_spec'

Dir[File.expand_path('support/**/*.rb', __dir__)].each { |f| require f }

FIXTURES_PATH = Pathname.new(__dir__).join('fixtures')
