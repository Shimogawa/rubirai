# frozen_string_literal: true

require 'simplecov'
SimpleCov.start do
  project_name 'rubirai'
  track_files 'lib/**/*.rb'
  add_filter '/spec/'
end

if ENV['CI'] == 'true'
  require 'codecov'
  SimpleCov.formatter = SimpleCov::Formatter::Codecov
end

require 'webmock/rspec'
require 'rspec'
require 'rubirai'

def new_bot
  Rubirai::Bot.new('test')
end

WebMock.disable_net_connect!(allow_localhost: false)

RSpec.configure do |config|
  config.before :all do
    @auth_key = 'test_auth_key'
    @session_key = 'test_session_key'
    @qq = 1145141919
  end
end
