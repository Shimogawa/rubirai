# frozen_string_literal: true

require 'spec_helper'

describe 'message api' do
  before :all do
    @mirai_bot = new_bot
  end

  after do
  end

  it 'converts objects to message chain' do
    chain = Rubirai.msg_to_chain 'hi', 2, Rubirai::AtMessage.from(target: 114514), 3, 'hi', :good
    arr = [
      { type: 'Plain', text: 'hi2' },
      { type: 'At', target: 114514 },
      { type: 'Plain', text: '3higood'}
    ].map(&:stringify_keys)
    expect(chain.to_a).to eq(arr)
  end
end
