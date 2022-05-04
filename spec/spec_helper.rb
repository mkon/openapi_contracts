require 'rubygems'
require 'bundler'
Bundler.require :default, 'test'

require 'rack'

require 'simplecov'
SimpleCov.start do
  add_filter '/spec'
end
SimpleCov.minimum_coverage 100

Dir[File.expand_path('support/**/*.rb', __dir__)].sort.each { |f| require f }

FIXTURES_PATH = Pathname.new(__dir__).join('fixtures')
