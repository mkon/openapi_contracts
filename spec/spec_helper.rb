require 'rubygems'
require 'bundler'
Bundler.require :default, 'test'

require 'simplecov'
SimpleCov.start do
  add_filter '/spec'
end
SimpleCov.minimum_coverage 90
