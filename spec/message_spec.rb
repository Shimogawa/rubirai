# frozen_string_literal: true

require 'spec_helper'

describe 'message api' do
  before :all do
    @mirai_bot = new_bot
  end

  after do
    # Do nothing
  end
end

describe 'messages and message chains' do
  before :all do
    @mirai_bot = new_bot
  end

  after do
    # Do nothing
  end

  it 'test' do
    a = Rubirai::PlainMessage.new(text: 'a')
    p a
  end
end
