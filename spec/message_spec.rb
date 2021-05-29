# frozen_string_literal: true

require 'spec_helper'

describe 'message api' do
  before :all do
    @mirai_bot = new_bot
    stub_login
    @mirai_bot.login @qq, @auth_key
  end

  after do
  end

  it 'should be able to send friend message' do
    stub_request(:post, @mirai_bot.gen_uri('/sendFriendMessage'))
      .with(body: {
        "sessionKey": @session_key,
        "target": 987654321,
        "messageChain": [
          { "type": 'Plain', "text": "hello\nworld" },
          { "type": 'Image', "url": 'a' }
        ]
      })
      .to_return(status: 200, body: %({
          "code": 0,
          "msg": "success",
          "messageId": 1234567890
      }))
    res = @mirai_bot.send_friend_msg 987654321, "hello\nworld", Rubirai::ImageMessage(url: 'a')
    expect(res).to eq(1234567890)
  end

  it 'should be able to send temp message' do
    stub_request(:post, @mirai_bot.gen_uri('/sendTempMessage'))
      .with(body: {
        "sessionKey": @session_key,
        "qq": 123,
        "group": 456,
        "messageChain": [
          { "type": 'Plain', "text": "hello\nworld" },
          { "type": 'Image', "url": 'a' }
        ]
      })
      .to_return(status: 200, body: %({
          "code": 0,
          "msg": "success",
          "messageId": 1234567890
      }))
    res = @mirai_bot.send_temp_msg 123, 456, "hello\nworld", Rubirai::ImageMessage(url: 'a')
    expect(res).to eq(1234567890)
  end

  it 'should be able to send group message' do
    stub_request(:post, @mirai_bot.gen_uri('/sendGroupMessage'))
      .with(body: {
        "sessionKey": @session_key,
        "target": 456,
        "messageChain": [
          { "type": 'Plain', "text": "hello\nworld" },
          { "type": 'Image', "url": 'a' }
        ]
      })
      .to_return(status: 200, body: %({
          "code": 0,
          "msg": "success",
          "messageId": 1234567890
      }))
    res = @mirai_bot.send_group_msg 456, "hello\nworld", Rubirai::ImageMessage(url: 'a')
    expect(res).to eq(1234567890)
  end

  it 'should be able to recall a message' do
    stub_request(:post, @mirai_bot.gen_uri('/recall'))
      .with(body: {
        "sessionKey": @session_key,
        "target": 123
      })
      .to_return(status: 200, body: %({
          "code": 0,
          "msg": "success"
      }))
    expect do
      expect(@mirai_bot.recall(123)).to be_nil
    end.not_to raise_error
  end
end
