require 'rubygems'
require 'bundler'
Bundler.require :default, 'test'

require 'simplecov'
SimpleCov.start do
  add_filter '/spec'
end
SimpleCov.minimum_coverage 80

FIXTURES_PATH = Pathname.new(__dir__).join('fixtures')
