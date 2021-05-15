# frozen_string_literal: true

require 'spec_helper'

describe 'plugin info api' do
  before do
    @mirai_bot = new_bot
  end

  after do
    # Do nothing
  end

  it 'should return the plugin info' do
    stub_request(:get, @mirai_bot.gen_uri('/about'))
      .to_return(status: 200, body: '{
          "code": 0,
          "errorMessage": "",
          "data": {
              "version": "v1.0.0"
          }
      }')
    res = @mirai_bot.about
    expect(res).to be_a_kind_of(Hash)
    expect(res).to have_key('version')
    expect(res['version']).to eq('v1.0.0')
  end
end
