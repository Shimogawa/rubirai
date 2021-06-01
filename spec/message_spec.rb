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

  it 'should be able to respond to a message event' do
    e = Rubirai::Event.parse({
      "type": 'GroupMessage',
      "messageChain": [
        {
          "type": 'Source',
          "id": 123456,
          "time": 123456789
        }.stringify_keys,
        {
          "type": 'Plain',
          "text": 'Miral牛逼'
        }.stringify_keys
      ],
      "sender": {
        "id": 123456789,
        "memberName": '化腾',
        "permission": 'MEMBER',
        "group": {
          "id": 1234567890,
          "name": 'Miral Technology',
          "permission": 'MEMBER'
        }.stringify_keys
      }.stringify_keys
    }.stringify_keys, @mirai_bot)
    stub_request(:post, @mirai_bot.gen_uri('/sendGroupMessage'))
      .with(body: {
        "sessionKey": 'test_session_key',
        "target": 1234567890,
        "messageChain": [
          {
            "id": 123456,
            "groupId": 1234567890,
            "senderId": 123456789,
            "targetId": 1234567890,
            "origin": [
              {
                "type": 'Source',
                "id": 123456,
                "time": 123456789
              },
              { "text": 'Miral牛逼', "type": 'Plain' }
            ],
            "type": 'Quote'
          },
          { "text": 'hi', "type": 'Plain' }
        ]
      })
      .to_return(status: 200, body: %({
          "code": 0,
          "msg": "success",
          "messageId": 1234567890
      }))
    expect(e).to be_a(Rubirai::GroupMessageEvent)
    msg_id = e.respond 'hi', quote: true
    expect(msg_id).to eq(1234567890)
  end
end
