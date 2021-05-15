# frozen_string_literal: true

require 'rubirai/utils'

module Rubirai
  # Section of Bot about messages
  class Bot
    def send_friend_msg(target_qq, msg)
      chain = case msg
              when String
                make_chain PlainMessage.from msg
              when Message, MessageChain
                msg
              when Hash
                make_chain Message.build_from msg
              else
                msg.to_s
              end
      resp = call :post, '/sendFriendMessage', json: {
        sessionKey: @session,
        target: target_qq,
        messageChain: chain.to_a
      }
      resp['messageId']
    end

    def make_chain(*msgs)
      MessageChain.make @qq, msgs
    end
  end

  class MessageChain
    attr_reader :sender_id, :send_time, :messages, :read_only

    def self.make(sender_id, *messages)
      res = new
      res.sender_id = sender_id
      res.extend(messages)
      res
    end

    def extend(*messages)
      messages.each do |msg|
        append msg
      end
      self
    end

    def append(msg)
      raise(RubiraiError, 'not a message or hash') unless msg.is_a?(Message) || msg.is_a?(Hash)

      if msg.is_a? Message
        @messages.append msg
        return self
      end
      @messages.append Message.build_from(msg)
      self
    end

    def initialize(source = nil)
      @messages = []
      return unless source
      raise(MiraiError, 'source is not array') unless source.class.is_a? Array
      raise(MiraiError, 'length is zero') if source.length.zero?

      if source[0].type == :Source
        @sender_id = source[0].id
        @send_time = source[0].time
        @messages = extend(source.drop(1))
      else
        @messages = extend(source)
      end
    end

    def to_a
      @messages.map(&:to_h)
    end

    private

    attr_writer :sender_id, :send_time
  end

  class Message
    attr_reader :type

    def self.all_types
      %i[
        Source Quote At AtAll Face Plain Image
        FlashImage Voice Xml Json App Poke Forward
        File MusicShare
      ]
    end

    def self.check_type(type)
      raise(RubiraiError, 'type not in all message types') unless Message.all_types.include? type
    end

    def self.get_msg_klass(type)
      Object.const_get "Rubirai::#{type}Message"
    end

    def self.build_from(hash)
      hash = hash.stringify_keys
      raise(RubiraiError, 'not a valid message') unless hash.key? 'type'

      type = msg['type'].to_sym
      check_type type
      klass = get_msg_klass type
      klass.new hash
    end

    def self.set_message(type, *attr_keys)
      attr_reader(*attr_keys)

      metaclass.instance_eval do
        define_method(:keys) do
          attr_keys
        end
        return if attr_keys.empty?
        define_method(:from) do |**kwargs|
          res = Message.get_msg_klass(type).new({})
          attr_keys.each do |key|
            res.instance_variable_set "@#{key}", kwargs[key]
          end
          res
        end
        s = +"def from_with_param(#{attr_keys.join('= nil, ')} = nil)\n"
        s << "res = Rubirai::#{type}Message.new({})\n"
        attr_keys.each do |key|
          s << %[res.instance_variable_set("@#{key}", #{key})\n]
        end
        s << "res\nend"
        class_eval s
      end

      class_eval do
        define_method(:initialize) do |hash|
          # noinspection RubySuperCallWithoutSuperclassInspection
          super type
          hash = hash.stringify_keys
          attr_keys.each do |k|
            instance_variable_set("@#{k}", hash[k.to_s.camel_case(lower: true)])
          end
        end
      end
    end

    def initialize(type)
      Message.check_type type
      @type = type
    end

    def to_h
      Hash(keys.map do |k|
        v = instance_variable_get("@#{k}")
        if v.respond_to? :to_h
          [k, v.to_h]
        else
          [k, v]
        end
      end).stringify_keys
    end

    def self.metaclass
      class << self
        self
      end
    end
  end

  class SourceMessage < Message
    set_message :Source, :id, :time
  end

  class QuoteMessage < Message
    set_message :Quote, :id, :group_id, :sender_id, :target_id, :origin

    def self.keys
      %i[id group_id sender_id target_id origin]
    end

    def initialize(hash)
      super :Quote
      @id = hash['id']
      @group_id = hash['groupId']
      @sender_id = hash['senderId']
      @target_id = hash['targetId']
      @origin = MessageChain.make @sender_id, hash['origin']
    end
  end

  class AtMessage < Message
    set_message :At, :target, :display
  end

  class AtAllMessage < Message
    set_message :AtAll
  end

  class FaceMessage < Message
    set_message :Face, :face_id, :name
  end

  class PlainMessage < Message
    set_message :Plain, :text
  end

  class ImageMessage < Message
    set_message :Image, :image_id, :url, :path
  end

  class FlashImageMessage < Message
    set_message :FlashImage, :image_id, :url, :path
  end

  class VoiceMessage < Message
    set_message :Voice, :voice_id, :url, :path
  end

  class XmlMessage < Message
    set_message :Xml, :xml
  end

  class JsonMessage < Message
    set_message :Json, :json
  end

  class AppMessage < Message
    set_message :App, :content
  end

  class PokeMessage < Message
    set_message :Poke, :name
  end

  class ForwardMessage < Message
    # todo: not implemented, maybe add a received message type to
    # reuse
    set_message :Forward, :hash
  end

  class FileMessage < Message
    set_message :File, :id, :internal_id, :name, :size
  end

  class MusicShareMessage < Message
    attr_reader :kind, :title, :summary, :jump_url, :picture_url, :music_url, :brief

    def self.all_kinds
      %w[NeteaseCloudMusic QQMusic MiguMusic]
    end

    def initialize(hash)
      super :MusicShare
      raise(RubiraiError, 'non valid music type') unless all_kinds.include? hash['kind']

      @kind = hash['kind']
      @title = hash['title']
      @summary = hash['summary']
      @jump_url = hash['jumpUrl']
      @picture_url = hash['pictureUrl']
      @music_url = hash['musicUrl']
      @brief = hash['brief']
    end
  end
end
