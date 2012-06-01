unless ENV['CI']
  require 'simplecov'
  SimpleCov.start do
    add_filter 'spec'
  end
end

require File.join(File.dirname(__FILE__), '..', 'flightboard.rb')

require 'sinatra'
require 'rack/test'
require 'webmock/rspec'

# setup test environment
set :environment, :test
set :run, false
set :raise_errors, true
set :logging, false

def app
  Sinatra::Application
end

RSpec.configure do |config|
  config.include Rack::Test::Methods
end
