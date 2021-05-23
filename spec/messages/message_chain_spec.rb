# frozen_string_literal: true

describe Rubirai::MessageChain do
  before do
  end

  after do
  end

  it 'converts objects to message chain' do
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
    chain = Rubirai::MessageChain.make(
      'hi', 2, Rubirai::AtMessage.from(target: 114514), 3, 'hi', :good, hash
    )
    arr = [
      { type: 'Plain', text: 'hi2' },
      { type: 'At', target: 114514 },
      { type: 'Plain', text: '3higood' },
      hash
    ].map(&:stringify_keys)
    expect(chain.to_a).to eq(arr)
  end
end
