require 'webmock/rspec'
require 'rspec'
require 'rubirai'

RSpec.configure do |config|
  config.before :all do
    @mirai_bot = Rubirai::RubiraiAPI.new("test")
  end
end
