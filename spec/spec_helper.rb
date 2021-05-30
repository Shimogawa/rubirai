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

def stub_login
  stub_request(:post, @mirai_bot.gen_uri('/auth'))
    .with(body: {
      "authKey": @auth_key
    })
    .to_return(status: 200, body: %({
          "code": 0,
          "session": "#{@session_key}"
      }))
  stub_request(:post, @mirai_bot.gen_uri('/verify'))
    .with(body: {
      "sessionKey": @session_key,
      "qq": @qq
    })
    .to_return(status: 200, body: %({
          "code": 0,
          "session": "success"
      }))
end
