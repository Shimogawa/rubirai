# frozen_string_literal: true

require 'rubirai/utils'

# @!method self.AtMessage(**kwargs)
#   Form an {Rubirai::AtMessage}. The `display` option has no effect when
#   sending at messages.
#   @option kwargs [Integer] :target the target id
#   @return [Rubirai::AtMessage] the message object
#   @see Rubirai::AtMessage.from
# @!method self.QuoteMessage(**kwargs)
#   Form a {Rubirai::QuoteMessage}.
#   @return [Rubirai::QuoteMessage] the message object
#   @see Rubirai::QuoteMessage.from
# @!method self.AtAllMessage()
#   Form an {Rubirai::AtAllMessage}.
#   @return [Rubirai::AtAllMessage] the message object
#   @see Rubirai::AtAllMessage.from
# @!method self.FaceMessage(**kwargs)
#   Form a {Rubirai::FaceMessage}. Only needs to give one of the two arguments.
#   @option kwargs [Integer] :face_id the face id (high priority)
#   @option kwargs [String] :name the face's name (low priority)
#   @return [Rubirai::FaceMessage] the message object
#   @see Rubirai::FaceMessage.from
# @!method self.PlainMessage(**kwargs)
#   @option kwargs [String] :text the plain text
#   @return [Rubirai::PlainMessage] the message object
#   @see Rubirai::PlainMessage.from
# @!method self.ImageMessage(**kwargs)
#   Form an {Rubirai::ImageMessage}. Only needs to give one of the three arguments.
#   @option kwargs [String] :image_id the image id
#   @option kwargs [String] :url the url of the image
#   @option kwargs [String] :path the local path of the image
#   @return [Rubirai::ImageMessage] the message object
#   @see Rubirai::ImageMessage.from
# @!method self.FlashImageMessage(**kwargs)
#   Form a {Rubirai::FlashImageMessage}. Only needs to give one of the three arguments.
#   @option kwargs [String] :image_id the image id
#   @option kwargs [String] :url the url of the image
#   @option kwargs [String] :path the local path of the image
#   @return [Rubirai::FlashImageMessage] the message object
#   @see Rubirai::FlashImageMessage.from
# @!method self.VoiceMessage(**kwargs)
#   Form a {Rubirai::VoiceMessage}. Only needs to give one of the three arguments.
#   @option kwargs [String] :voice_id the voice id
#   @option kwargs [String] :url the url of the voice
#   @option kwargs [String] :path the local path of the voice
#   @return [Rubirai::VoiceMessage] the message object
#   @see Rubirai::VoiceMessage.from
# @!method self.XmlMessage(**kwargs)
#   Form a {Rubirai::XmlMessage}.
#   @option kwargs [String] :xml the xml body
#   @return [Rubirai::XmlMessage] the message object
#   @see Rubirai::XmlMessage.from
# @!method self.JsonMessage(**kwargs)
#   Form a {Rubirai::JsonMessage}.
#   @option kwargs [String] :json the json body
#   @return [Rubirai::JsonMessage] the message object
#   @see Rubirai::JsonMessage.from
# @!method self.AppMessage(**kwargs)
#   Form an {Rubirai::AppMessage}.
#   @option kwargs [String] :content the app body
#   @return [Rubirai::AppMessage] the message object
#   @see Rubirai::AppMessage.from
# @!method self.PokeMessage(**kwargs)
#   Form a {Rubirai::PokeMessage}.
#   @option kwargs [String] :name the poke name
#   @return [Rubirai::PokeMessage] the message object
#   @see Rubirai::PokeMessage.from
module Rubirai
  # The message abstract class.
  #
  # @abstract
  class Message
    # @!attribute [r] bot
    #   @return [Bot] the bot
    # @!attribute [r] type
    #   @return [Symbol] the type
    attr_reader :bot, :type

    # Objects to {Rubirai::Message}
    #
    # @param msg [Rubirai::Message, Hash{String => Object}, Object] the object to transform to a message
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

    # @private
    def self.get_msg_klass(type)
      Object.const_get "Rubirai::#{type}Message"
    end

    # @private
    def self.build_from(hash, bot = nil)
      hash = hash.stringify_keys
      raise(RubiraiError, 'not a valid message') unless hash.key? 'type'

      type = hash['type'].to_sym
      check_type type
      klass = get_msg_klass type
      klass.new hash, bot
    end

    # @private
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

    # @private
    def initialize(type, bot = nil)
      Message.check_type type
      @bot = bot
      @type = type
    end

    # Convert the message to a hash
    #
    # @return [Hash{String => Object}]
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

    # @private
    def self.metaclass
      class << self
        self
      end
    end
  end

  # {include:Rubirai::Message.to_message}
  # @param obj [Message, Hash{String => Object}, Object] the object
  # @return [Message] the message
  # @see Rubirai::Message.to_message
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
    # @!method from(**kwargs)
    #   @option kwargs [Integer] :id the id
    #   @option kwargs [Integer] :time the timestamp
    #   @!scope class
    set_message :Source, :id, :time
  end

  # The quote message type
  class QuoteMessage < Message
    # @!attribute [r] id
    #   @return [Integer] the original (quoted) message chain id
    # @!attribute [r] group_id
    #   @return [Integer] the group id. `0` if from friend.
    # @!attribute [r] sender_id
    #   @return [Integer] the original sender's id
    # @!attribute [r] target_id
    #   @return [Integer] the original receiver's (group or user) id
    # @!attribute [r] origin
    #   @return [MessageChain] the original message chain
    # @!method from(**kwargs)
    #   Form a {QuoteMessage}.
    set_message :Quote, :id, :group_id, :sender_id, :target_id, :origin, :origin_raw

    # @private
    def initialize(hash, bot = nil)
      super :Quote, bot
      @id = hash['id']
      @group_id = hash['groupId']
      @sender_id = hash['senderId']
      @target_id = hash['targetId']
      @origin = MessageChain.make(*hash['origin'], bot: bot)
      @origin_raw = hash['origin']
    end

    def to_h
      {
        "type" => "Quote",
        "id" => @id,
        "groupId" => @group_id,
        "senderId" => @sender_id,
        "targetId" => @target_id,
        "origin" => if @origin_raw then @origin_raw else @origin.to_a end
      }.compact
    end
  end

  # The At message type
  class AtMessage < Message
    # @!attribute [r] target
    #   @return [Integer] the target group user's id
    # @!attribute [r] display
    #   @return [String] the displayed name (not used when sending)
    # @!method from(**kwargs)
    #   Form an {AtMessage}. The `display` option has no effect when
    #   sending at messages.
    #   @option kwargs [Integer] :target the target id
    #   @return [AtMessage] the message object
    set_message :At, :target, :display
  end

  # The At All message type
  class AtAllMessage < Message
    # @!method from()
    #   @return [AtAllMessage] the message object
    set_message :AtAll
  end

  # The QQ Face Emoji message type
  class FaceMessage < Message
    # @!attribute [r] face_id
    #   @return [Integer] the face's id
    # @!attribute [r] name
    #   @return [String, nil] the face's name
    # @!method from(**kwargs)
    #   Form a {Rubirai::FaceMessage}. Only needs to give one of the two arguments.
    #   @option kwargs [Integer] :face_id the face id (high priority)
    #   @option kwargs [String] :name the face's name (low priority)
    #   @return [Rubirai::FaceMessage] the message object
    #   @!scope class
    set_message :Face, :face_id, :name
  end

  # The plain text message type
  class PlainMessage < Message
    # @!attribute [r] text
    #   @return [String] the text
    # @!method from(**kwargs)
    #   @option kwargs [String] :text the plain text
    #   @return [PlainMessage] the message object
    #   @!scope class
    set_message :Plain, :text
  end

  # The image message type.
  # Only one out of the three fields is needed to form the message.
  class ImageMessage < Message
    # @!attribute [r] image_id
    #   @return [String, nil] the image id from mirai
    # @!attribute [r] url
    #   @return [String, nil] the url of the image
    # @!attribute [r] path
    #   @return [String, nil] the local path of the image
    # @!method from(**kwargs)
    #   Form an {Rubirai::ImageMessage}. Only needs to give one of the three arguments.
    #   @option kwargs [String] :image_id the image id
    #   @option kwargs [String] :url the url of the image
    #   @option kwargs [String] :path the local path of the image
    #   @return [Rubirai::ImageMessage] the message object
    #   @!scope class
    set_message :Image, :image_id, :url, :path
  end

  # The flash image message type
  class FlashImageMessage < Message
    # @!attribute [r] image_id
    #   @return [String, nil] the image id from mirai
    # @!attribute [r] url
    #   @return [String, nil] the url of the image
    # @!attribute [r] path
    #   @return [String, nil] the local path of the image
    # @!method from(**kwargs)
    #   Form a {Rubirai::FlashImageMessage}. Only needs to give one of the three arguments.
    #   @option kwargs [String] :image_id the image id
    #   @option kwargs [String] :url the url of the image
    #   @option kwargs [String] :path the local path of the image
    #   @return [Rubirai::FlashImageMessage] the message object
    #   @!scope class
    set_message :FlashImage, :image_id, :url, :path
  end

  # The voice message type
  class VoiceMessage < Message
    # @!attribute [r] voice_id
    #   @return [String, nil] the voice id from mirai
    # @!attribute [r] url
    #   @return [String, nil] the url of the voice
    # @!attribute [r] path
    #   @return [String, nil] the local path of the voice
    # @!method from(**kwargs)
    #   Form a {Rubirai::VoiceMessage}. Only needs to give one of the three arguments.
    #   @option kwargs [String] :voice_id the voice id
    #   @option kwargs [String] :url the url of the voice
    #   @option kwargs [String] :path the local path of the voice
    #   @return [Rubirai::VoiceMessage] the message object
    #   @!scope class
    set_message :Voice, :voice_id, :url, :path
  end

  # The xml message type
  class XmlMessage < Message
    # @!attribute [r] xml
    #   @return [String] the xml content
    # @!method from(**kwargs)
    #   Form a {Rubirai::XmlMessage}.
    #   @option kwargs [String] :xml the xml body
    #   @return [Rubirai::XmlMessage] the message object
    #   @!scope class
    set_message :Xml, :xml
  end

  # The json message type
  class JsonMessage < Message
    # @!attribute [r] json
    #   @return [String] the json content
    # @!method from(**kwargs)
    #   Form a {Rubirai::JsonMessage}.
    #   @option kwargs [String] :json the json body
    #   @return [Rubirai::JsonMessage] the message object
    #   @!scope class
    set_message :Json, :json
  end

  # The app message type
  class AppMessage < Message
    # @!attribute [r] content
    #   @return [String] the app content
    # @!method from(**kwargs)
    #   Form an {Rubirai::AppMessage}.
    #   @option kwargs [String] :content the app body
    #   @return [Rubirai::AppMessage] the message object
    #   @!scope class
    set_message :App, :content
  end

  # The poke message type
  class PokeMessage < Message
    # @!attribute [r] name
    #   @return [String] type (name) of the poke
    # @!method from(**kwargs)
    #   Form an {Rubirai::PokeMessage}.
    #   @option kwargs [String] :name the name (type) of poke
    #   @return [Rubirai::PokeMessage] the message object
    #   @!scope class
    set_message :Poke, :name
  end

  # The forward message type
  class ForwardMessage < Message
    # A message node in the forward message list
    #
    # @!attribute [r] sender_id
    #   @return [Integer] sender id
    # @!attribute [r] time
    #   @return [Integer] send timestamp (second)
    # @!attribute [r] sender_name
    #   @return [String] the sender name
    # @!attribute [r] message_chain
    #   @return [MessageChain] the message chain
    class Node
      attr_reader :sender_id, :time, :sender_name, :message_chain

      # @private
      def initialize(hash, bot = nil)
        return unless hash
        @sender_id = hash['senderId']
        @time = hash['time']
        @sender_name = hash['senderName']
        @message_chain = MessageChain.make(*hash['messageChain'], bot: bot)
      end

      def self.from(**kwargs)
        n = new({})
        %i[sender_id time sender_name message_chain].each do |attr|
          n.instance_variable_set("@#{attr}", kwargs[attr])
        end
      end
    end

    # @!attribute [r] title
    #   @return [String] the title
    # @!attribute [r] brief
    #   @return [String] the brief text
    # @!attribute [r] source
    #   @return [String] the source text
    # @!attribute [r] summary
    #   @return [String] the summary text
    # @!attribute [r] node_list
    #   @return [Array<Node>] the node list
    #   @see Node
    set_message :Forward, :title, :brief, :source, :summary, :node_list

    # @private
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

  # The file message type
  class FileMessage < Message
    # @!attribute [r] id
    #   @return [String] the file id
    # @!attribute [r] internal_id
    #   @return [Integer] the internal id needed by server
    # @!attribute [r] name
    #   @return [String] the filename
    # @!attribute [r] size
    #   @return [Integer] the file size
    set_message :File, :id, :internal_id, :name, :size
  end

  # The music share card message
  class MusicShareMessage < Message
    # List all kinds of music providers
    #
    # @return [Array<String>] kinds
    def self.all_kinds
      %w[NeteaseCloudMusic QQMusic MiguMusic]
    end

    # @!attribute [r] kind
    #   @return [String] the kind of music provider
    # @!attribute [r] title
    #   @return [String] the music card title
    # @!attribute [r] summary
    #   @return [String] the music card summary
    # @!attribute [r] jump_url
    #   @return [String] the jump url
    # @!attribute [r] picture_url
    #   @return [String] the picture's url
    # @!attribute [r] music_url
    #   @return [String] the music's url
    # @!attribute [r] brief
    #   @return [String, nil] the brief message (optional)
    set_message :MusicShare, :kind, :title, :summary, :jump_url, :picture_url, :music_url, :brief do |hash|
      raise(RubiraiError, 'non valid music type') unless all_kinds.include? hash['kind']
    end
  end
end
