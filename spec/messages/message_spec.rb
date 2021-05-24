# frozen_string_literal: true

describe Rubirai::Message do
  before do
  end

  after do
  end

  it 'should initialize and convert Source messages correctly' do
    hash = {
      'type' => 'Source',
      'id' => 123456,
      'time' => 123456
    }
    sm = Rubirai::SourceMessage.new hash
    expect(sm).to be_a(Rubirai::SourceMessage)
    expect(sm.time).to eq(123456)
    expect(sm.id).to eq(123456)
    expect(sm.bot).to be_nil
    expect(sm.type).to eq(:Source)

    expect(sm.to_h).to eq(hash)
  end

  it 'should initialize and convert Quote message correctly' do
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
    qm = Rubirai::QuoteMessage.new hash
    expect(qm.id).to eq(123456)
    expect(qm.origin).to be_a(Rubirai::MessageChain)
    expect(qm.origin.sender_id).to eq(987654321)
    expect(qm.origin.messages).to be_a(Array)
    expect(qm.origin.messages.length).to eq(1)
    expect(qm.origin.messages[0]).to be_a(Rubirai::Message)
    expect(qm.origin.messages[0].type).to eq(:Plain)
    expect(qm.origin.messages[0].text).to eq('text')

    expect(qm.to_h).to eq(hash)
  end

  it 'should initialize and convert At message correctly' do
    hash = {
      "type": 'At',
      "target": 123456,
      "display": '@Mirai'
    }.stringify_keys
    am = Rubirai::AtMessage.new hash
    expect(am.type).to eq(:At)
    expect(am.target).to eq(123456)
    expect(am.display).to eq('@Mirai')

    expect(am.to_h).to eq(hash)
    expect(Rubirai::AtMessage.from(target: 114514).to_h).to eq({
      'type' => 'At',
      'target' => 114514
    })
  end

  it 'should initialize and convert AtAll message correctly' do
    hash = { 'type' => 'AtAll' }
    aam = Rubirai::AtAllMessage.new hash
    expect(aam.type).to eq(:AtAll)
    expect(aam.bot).to eq(nil)

    expect(aam.to_h).to eq(hash)
  end

  it 'should initialize and convert Face message correctly' do
    hash = {
      "type": 'Face',
      "faceId": 123,
      "name": 'bu'
    }.stringify_keys
    fm = Rubirai::FaceMessage.new hash
    expect(fm.type).to eq(:Face)
    expect(fm.face_id).to eq(123)
    expect(fm.name).to eq('bu')

    expect(fm.to_h).to eq(hash)
  end

  it 'should initialize and convert Plain message correctly' do
    hash = {
      "type": 'Plain',
      "text": 'Mirai牛逼'
    }.stringify_keys
    pm = Rubirai::PlainMessage.new hash
    expect(pm.type).to eq(:Plain)
    expect(pm.text).to eq('Mirai牛逼')

    expect(pm.to_h).to eq(hash)
  end

  it 'should initialize and convert Image message correctly' do
    hash = {
      "type": 'Image',
      "imageId": '{01E9451B-70ED-EAE3-B37C-101F1EEBF5B5}.mirai',
      "path": nil
    }.stringify_keys
    im = Rubirai::ImageMessage.new hash
    expect(im.type).to eq(:Image)
    expect(im.path).to be_nil
    expect(im.image_id).to eq(hash['imageId'])

    expect(im.to_h).to eq(hash.compact)
  end

  it 'should initialize and convert music share message correctly' do
    hash = {
      "type": 'MusicShare',
      "kind": 'NeteaseCloudMusic',
      "title": '相见恨晚',
      "summary": '彭佳慧',
      "jumpUrl": 'https://y.music.163.com/m/song/280761/',
      "pictureUrl": 'http://p4.music.126.net/GpsgjHB_9XgtrBVXt8XX4w==/93458488373078.jpg',
      "musicUrl": 'http://music.163.com/song/media/outer/url?id=280761&userid=52707509',
      "brief": '[分享]相见恨晚'
    }.stringify_keys
    msm = Rubirai::MusicShareMessage.new hash
    expect(msm.type).to eq(:MusicShare)
    expect(msm.kind).to eq(hash['kind'])
    expect(msm.jump_url).to eq(hash['jumpUrl'])
    expect(msm.music_url).to eq(hash['musicUrl'])
  end

  it 'should build correctly from hash' do
    hash = {
      "type": 'Face',
      "faceId": 123,
      "name": 'bu'
    }.stringify_keys
    msg = Rubirai::Message.build_from hash
    expect(msg).to be_a(Rubirai::FaceMessage)
    expect(msg.to_h).to eq(hash)

    bot = Rubirai::Bot.new 'test'
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
    msg = Rubirai::Message.build_from hash, bot
    expect(msg).to be_a(Rubirai::QuoteMessage)
    expect(msg.bot).to eq(bot)
    expect(msg.to_h).to eq(hash)
  end

  it 'should have kind of constructor methods' do
    Rubirai::Message.all_types.each do |type|
      expect(Rubirai.class.method_defined?("#{type}Message")).to be_truthy
    end

    am = Rubirai::AtMessage(target: 123456)
    expect(am).to be_a(Rubirai::AtMessage)
    expect(am.target).to eq(123456)
  end
end
