# frozen_string_literal: true

require 'spec_helper'

describe 'rubirai bot' do
  before do
    # Do nothing
  end

  after do
    # Do nothing
  end

  it 'should be able to generate a new bot' do
    res = Rubirai::Bot.new 'test', 123
    expect(res).to be_a_kind_of(Rubirai::Bot)
  end

  it 'should generate correct uri' do
    bot = Rubirai::Bot.new 'test_hostname', 1145
    uri = bot.gen_uri('path')
    expect(uri).to be_a_kind_of(URI::HTTP)
    expect(uri.to_s).to eq('http://test_hostname:1145/path')

    expect(bot.gen_uri('/a/').to_s).to eq('http://test_hostname:1145/a/')

    bot = Rubirai::Bot.new 'host'
    expect(bot.gen_uri('/b').to_s).to eq('http://host/b')
  end
end
