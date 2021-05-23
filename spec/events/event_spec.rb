# frozen_string_literal: true

describe Rubirai::Event do
  before do
  end

  after do
  end

  it 'should parse hash to a bot online event' do
    hash = {
      "type": 'BotOnlineEvent',
      "qq": 123456
    }.stringify_keys
    e = Rubirai::Event.parse hash
    expect(e).to be_a(Rubirai::Event)
    expect(e).to be_a(Rubirai::BotEvent)
    expect(e).to be_a(Rubirai::BotOnlineEvent)
    expect(e.qq).to eq(hash['qq'])
  end

  it 'should parse hash to a bot active offline event' do
    hash = {
      "type": 'BotOfflineEventActive',
      "qq": 123456
    }.stringify_keys
    e = Rubirai::Event.parse hash
    expect(e).to be_a(Rubirai::BotActiveOfflineEvent)
    expect(e.qq).to eq(hash['qq'])
  end

  it 'should parse hash to a bot forced offline event' do
    hash = {
      "type": 'BotOfflineEventForce',
      "qq": 123456
    }.stringify_keys
    e = Rubirai::Event.parse hash
    expect(e).to be_a(Rubirai::BotForcedOfflineEvent)
    expect(e.qq).to eq(hash['qq'])
  end

  it 'should parse hash to a bot dropped event' do
    hash = {
      "type": 'BotOfflineEventDropped',
      "qq": 123456
    }.stringify_keys
    e = Rubirai::Event.parse hash
    expect(e).to be_a(Rubirai::BotDroppedEvent)
    expect(e.qq).to eq(hash['qq'])
  end

  it 'should parse hash to a bot relogin event' do
    hash = {
      "type": 'BotReloginEvent',
      "qq": 123456
    }.stringify_keys
    e = Rubirai::Event.parse hash
    expect(e).to be_a(Rubirai::BotReloginEvent)
    expect(e.qq).to eq(hash['qq'])
  end

  it 'should parse hash to a bot permission change event' do
    hash = {
      "type": 'BotGroupPermissionChangeEvent',
      "origin": 'MEMBER',
      "new": 'ADMINISTRATOR',
      "current": 'ADMINISTRATOR',
      "group": {
        "id": 123456789,
        "name": 'Mirai Technology',
        "permission": 'ADMINISTRATOR'
      }
    }
    e = Rubirai::Event.parse hash
    expect(e).to be_a(Rubirai::BotGroupPermissionChangedEvent)
    expect(e.class.type)
  end
end
