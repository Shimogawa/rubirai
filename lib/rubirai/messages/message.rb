# frozen_string_literal: true

require 'rubirai/utils'

module Rubirai
  # The message abstract class.
  #
  # @abstract
  # @!method self.AtMessage(**kwargs)
  #   @param kwargs [Hash{Symbol => Object}] arguments
  #   @return [Rubirai::AtMessage]
  # @!method self.QuoteMessage(**kwargs)
  #   @param kwargs [Hash{Symbol => Object}] arguments
  #   @return [Rubirai::QuoteMessage]
  # @!method self.AtAllMessage(**kwargs)
  #   @param kwargs [Hash{Symbol => Object}] arguments
  #   @return [Rubirai::AtAllMessage]
  # @!method self.FaceMessage(**kwargs)
  #   @param kwargs [Hash{Symbol => Object}] arguments
  #   @return [Rubirai::FaceMessage]
  # @!method self.PlainMessage(**kwargs)
  #   @option text [String] the plain text
  #   @return [Rubirai::PlainMessage]
  class Message
    attr_reader :bot, :type

    # Objects to {Rubirai::Message}
    #
    # @param msg [Rubirai::Message, Hash, Object] the object to transform to a message
    # @return [Rubirai::Message] the message
    def self.to_message(msg, bot = nil)
      # noinspection RubyYardReturnMatch
      case msg
      when Message, MessageChain
        msg
      when Hash
        Message.build_from(msg, bot)
      else
        PlainMessage.from(text: msg.to_s, bot: bot)
      end
    end

    # Get all message types (subclasses)
    #
    # @return [Array<Symbol>] all message types
    def self.all_types
      %i[
        Source Quote At AtAll Face Plain Image
        FlashImage Voice Xml Json App Poke Forward
        File MusicShare
      ]
    end

    # Check if a type is in all message types
    # @param type [Symbol] the type to check
    # @return whether the type is in all message types
    def self.check_type(type)
      raise(RubiraiError, 'type not in all message types') unless Message.all_types.include? type
    end

    def self.get_msg_klass(type)
      Object.const_get "Rubirai::#{type}Message"
    end

    def self.build_from(hash, bot = nil)
      hash = hash.stringify_keys
      raise(RubiraiError, 'not a valid message') unless hash.key? 'type'

      type = hash['type'].to_sym
      check_type type
      klass = get_msg_klass type
      klass.new hash, bot
    end

    def self.set_message(type, *attr_keys, &initialize_block)
      attr_reader(*attr_keys)

      metaclass.instance_eval do
        define_method(:keys) do
          attr_keys
        end
        break if attr_keys.empty?
        define_method(:from) do |bot: nil, **kwargs|
          res = get_msg_klass(type).new({}, bot)
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
        define_method(:initialize) do |hash, bot = nil|
          # noinspection RubySuperCallWithoutSuperclassInspection
          super type, bot
          initialize_block&.call(hash)
          hash = hash.stringify_keys
          attr_keys.each do |k|
            instance_variable_set("@#{k}", hash[k.to_s.snake_to_camel(lower: true)])
          end
        end
      end
    end

    def initialize(type, bot = nil)
      Message.check_type type
      @bot = bot
      @type = type
    end

    def to_h
      res = self.class.keys.to_h do |k|
        v = instance_variable_get("@#{k}")
        k = k.to_s.snake_to_camel(lower: true)
        if v.is_a? MessageChain
          [k, v.to_a]
        elsif v&.respond_to?(:to_h)
          [k, v.to_h]
        else
          [k, v]
        end
      end
      res[:type] = @type.to_s
      res.compact.stringify_keys
    end

    def self.metaclass
      class << self
        self
      end
    end
  end

  def self.Message(obj, bot = nil)
    Message.to_message obj, bot
  end

  Message.all_types.each do |type|
    self.class.define_method("#{type}Message".to_sym) do |**kwargs|
      Message.get_msg_klass(type).from(**kwargs)
    end
  end

  # The source message type
  class SourceMessage < Message
    # @!attribute [r] id
    #   @return [Integer] the message (chain) id
    # @!attribute [r] time
    #   @return [Integer] the timestamp
    set_message :Source, :id, :time
  end

  # The quote message type
  class QuoteMessage < Message
    # @!attribute [r] id
    #   @return [Integer] the original (quoted) message (chain) id
    # @!attribute [r] group_id
    #   @return [Integer] the group id
    # @!attribute [r] sender_id
    #   @return [Integer] the original sender's id
    # @!attribute [r] target_id
    #   @return [Integer] the original receiver's (group or user) id
    # @!attribute [r] origin
    #   @return [MessageChain] the original message chain
    set_message :Quote, :id, :group_id, :sender_id, :target_id, :origin

    def initialize(hash, bot = nil)
      super :Quote, bot
      @id = hash['id']
      @group_id = hash['groupId']
      @sender_id = hash['senderId']
      @target_id = hash['targetId']
      @origin = MessageChain.make(*hash['origin'], sender_id: @sender_id, bot: bot)
    end
  end

  # The At message type
  class AtMessage < Message
    # @!attribute [r] target
    #   @return [Integer] the target group user's id
    # @!attribute [r] display
    #   @return [String] the displayed name (not used when sending)
    # @!method from(**kwargs)
    #   @param kwargs [Hash{Symbol => Object}] not used
    #   @return [AtMessage] the message object
    set_message :At, :target, :display
  end

  # The At All message type
  class AtAllMessage < Message
    # @!method from(**kwargs)
    #   @param kwargs [Hash{Symbol => Object}] the fields to set
    #   @return [AtAllMessage] the message object
    set_message :AtAll
  end

  # The QQ Face Emoji message type
  class FaceMessage < Message
    # @!attribute [r] face_id
    #   @return [Integer] the face's id
    # @!attribute [r] name
    #   @return [String, nil] the face's name
    set_message :Face, :face_id, :name
  end

  # The plain text message type
  class PlainMessage < Message
    # @!attribute [r] text
    #   @return [String] the text
    set_message :Plain, :text
  end

  # The image message type.
  # Only one out of the three fields is needed to form the message.
  class ImageMessage < Message
    # @!attribute [r] image_id
    #   @return [Integer, nil] the image id from mirai
    # @!attribute [r] url
    #   @return [String, nil] the url of the image
    # @!attribute [r] path
    #   @return [String, nil] the local path of the image
    set_message :Image, :image_id, :url, :path
  end

  # The flash image message type
  class FlashImageMessage < Message
    set_message :FlashImage, :image_id, :url, :path
  end

  # The voice message type
  class VoiceMessage < Message
    set_message :Voice, :voice_id, :url, :path
  end

  # The xml message type
  class XmlMessage < Message
    # @!attribute [r] xml
    #   @return [String] the xml content
    set_message :Xml, :xml
  end

  # The json message type
  class JsonMessage < Message
    # @!attribute [r] json
    #   @return [String] the json content
    set_message :Json, :json
  end

  # The app message type
  class AppMessage < Message
    # @!attribute [r] content
    #   @return [String] the app content
    set_message :App, :content
  end

  class PokeMessage < Message
    set_message :Poke, :name
  end

  class ForwardMessage < Message
    class Node
      attr_reader :sender_id, :time, :sender_name, :message_chain

      def initialize(hash, bot = nil)
        @sender_id = hash['senderId']
        @time = hash['time']
        @sender_name = hash['senderName']
        @message_chain = MessageChain.make(*hash['messageChain'], sender_id: hash['senderId'], bot: bot)
      end
    end

    set_message :Forward, :title, :brief, :source, :summary, :node_list

    def initialize(hash, bot = nil)
      super :Forward, bot
      @title = hash['title']
      @brief = hash['brief']
      @source = hash['source']
      @summary = hash['summary']
      @node_list = hash['nodeList'].each do |chain|
        Node.new chain, bot
      end
    end
  end

  class FileMessage < Message
    set_message :File, :id, :internal_id, :name, :size
  end

  class MusicShareMessage < Message
    def self.all_kinds
      %w[NeteaseCloudMusic QQMusic MiguMusic]
    end

    set_message :MusicShare, :kind, :title, :summary, :jump_url, :picture_url, :music_url, :brief do |hash|
      raise(RubiraiError, 'non valid music type') unless all_kinds.include? hash['kind']
    end
  end
end
