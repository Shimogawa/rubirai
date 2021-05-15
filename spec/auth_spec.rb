# frozen_string_literal: true

require 'spec_helper'

describe 'auth api' do
  before :all do
    @mirai_bot = new_bot
  end

  after do
    # Do nothing
  end

  it 'should be able to authenticate' do
    stub_request(:post, @mirai_bot.gen_uri('/auth'))
      .with(body: {
        "authKey": @auth_key
      })
      .to_return(status: 200, body: %({
          "code": 0,
          "session": "#{@session_key}"
      }))
    res = @mirai_bot.auth @auth_key
    expect(res).to be_a_kind_of(String)
    expect(res).to eq(@session_key)
  end

  it 'should raise error if authenticate fails' do
    mirai_bot = new_bot
    stub_request(:post, @mirai_bot.gen_uri('/auth'))
      .with(body: {
        "authKey": @auth_key
      })
      .to_return(status: 200, body: %({
          "code": 1,
          "session": ""
      }))

    expect { mirai_bot.auth @auth_key }.to raise_error(
      Rubirai::MiraiError,
      'Mirai error: 1 - Wrong auth key'
    )
  end

  it 'should be able to verify' do
    stub_request(:post, @mirai_bot.gen_uri('/verify'))
      .with(body: {
        "sessionKey": @session_key,
        "qq": @qq
      })
      .to_return(status: 200, body: %({
          "code": 0,
          "session": "success"
      }))

    expect { @mirai_bot.verify @qq }.not_to raise_error
    expect(@mirai_bot.verify(@qq)).to be_nil

    expect { @mirai_bot.verify '1ab39cde' }.to raise_error(Rubirai::RubiraiError, 'Wrong format for qq')
    expect { new_bot.verify @qq }.to raise_error(Rubirai::RubiraiError, 'No session provided')
  end
end

