# frozen_string_literal: true

describe Rubirai::MessageChain do
  before do
    hash = {
      "type": 'Quote',
      "id": 123456,
      "groupId": 123456789,
      "senderId": 987654321,
      "targetId": 9876543210,
      "origin": [
        { "type": 'Plain', text: 'text' }.stringify_keys
      ]
    }.stringify_keys
    @obj = Rubirai::AtMessage.from(target: 114514)
    @chain = Rubirai::MessageChain.make(
      'hi%', 2, @obj, 3, 'great %%,', :good, hash
    )
    @expect_pattern = /^hi%%2%[a-zA-Z0-9]{6}%3great %%%%,good%[a-zA-Z0-9]{6}%$/
  end

  after do
  end

  it 'should convert message chains to strings correctly' do
    expect(@chain.has_interpolation).to be_falsey

    str = @chain.interpolated_str
    expect(@chain.has_interpolation).to be_truthy
    objs_map = @chain.instance_variable_get('@ipl_objs_map')
    expect(objs_map.length).to be(2)
    objs_map.each_key do |k|
      expect(str.include?(k)).to be_truthy
    end
    expect(@expect_pattern.match?(str)).to be_truthy
    expect(@chain.interpolated_str).to eq(str)
  end

  it 'should get back the original object' do
    str = @chain.interpolated_str
    idx = 5
    obj = @chain.get_object(str[idx...idx + 8])
    expect(obj).to eq(@obj)
    obj = @chain.get_object(str[idx + 1...idx + 7])
    expect(obj).to eq(@obj)
    expect(@chain.get_object(str[idx + 2...idx + 8])).to be_nil
  end

  it 'should construct new message chain for interpolated strings' do
    str = @chain.interpolated_str[5...5 + 8 + 3]
    chain = @chain.chain_from_interpolated(str)
    expect(chain.length).to eq(2)
    expect(chain[0]).to eq(@obj)
    expect(chain[1]).to be_a(Rubirai::PlainMessage)
    expect(chain[1].text).to eq('3gr')

    chain = @chain.chain_from_interpolated(@chain.interpolated_str)
    expect(chain.length).to eq(@chain.length)
    expect(chain[0].text).to eq('hi%2')
    expect(chain[1]).to eq(@obj)
    expect(chain[2].text).to eq('3great %%,good')
    expect(chain[3]).to be_a(Rubirai::QuoteMessage)
  end
end
