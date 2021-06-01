# frozen_string_literal: true

require 'rubirai/utils'
require 'rubirai/messages/message'

module Rubirai
  # Message chain
  class MessageChain
    include Enumerable

    # @!attribute [r] bot
    #   @return [Bot] the bot object
    # @!attribute [r] id
    #   @return [Integer, nil] the message id, may be `nil`
    # @!attribute [r] raw
    #   @return [Hash{String => Object}, nil] the raw message chain, may be `nil`
    # @!attribute [r] send_time
    #   @return [Integer, nil] the send time of the message chain, may be `nil`
    # @!attribute [r] messages
    #   @return [Array<Message>] the raw message array
    attr_reader :bot, :id, :raw, :send_time, :messages

    # Makes a message chain from a list of messages
    #
    # @param messages [Array<Rubirai::Message, Rubirai::MessageChain, Hash, String, Object>] a list of messages
    # @param bot [Rubirai::Bot, nil]
    # @return [Rubirai::MessageChain] the message chain
    def self.make(*messages, bot: nil)
      chain = new(bot)
      result = []
      messages.map { |msg| Message.to_message(msg, bot) }.each do |msg|
        if !result.empty? && result[-1].is_a?(PlainMessage) && msg.is_a?(PlainMessage)
          result[-1] = PlainMessage.from(text: result[-1].text + msg.text, bot: bot)
        else
          result.append msg
        end
      end
      chain.extend(*result)
      chain
    end

    # Append messages to this message chain
    #
    # @param messages [Array<Rubirai::Message, Hash>] a list of messages
    # @return [Rubirai::MessageChain] self
    def extend(*messages)
      messages.each do |msg|
        internal_append msg
      end
      self
    end

    alias << extend
    alias append extend

    # Concats this message chain with another one
    #
    # @param msg_chain [MessageChain] another message chain
    # @return [MessageChain] self
    def concat!(msg_chain)
      msg_chain.messages.each do |msg|
        internal_append msg
      end
      self
    end

    def [](idx)
      @messages[idx]
    end

    def each(&block)
      @messages.each(&block)
    end

    def length
      @messages.length
    end

    def size
      @messages.size
    end

    def empty?
      @messages.empty?
    end

    # Don't use the constructor. Use {.make}.
    #
    # @private
    # @param bot [Rubirai::Bot, nil]
    # @param source [Array, nil]
    def initialize(bot = nil, source = nil)
      @bot = bot
      @messages = []
      @raw = source
      return unless source
      raise(MiraiError, 'source is not array') unless source.is_a? Array
      raise(MiraiError, 'length is zero') if source.empty?

      if source[0]['type'] == 'Source'
        @id = source[0]['id']
        @send_time = source[0]['time']
        extend(*source.drop(1))
      else
        extend(*source)
      end
    end

    # Convert the message chain to an array of hashes.
    #
    # @return [Array<Hash{String => Object}>]
    def to_a
      @messages.map(&:to_h)
    end

    private

    def internal_append(msg)
      msg.must_be! [Message, MessageChain, Hash], RubiraiError, 'msg must be Message, MessageChain, or Hash'

      case msg
      when Message
        @messages.append msg
      when MessageChain
        @messages.append(*msg.messages)
      else
        @messages.append Message.build_from(msg, @bot)
      end

      self
    end
  end

  # Makes a message chain. See {MessageChain#make}.
  #
  # @return [MessageChain] the message chain made.
  # @see MessageChain#make
  def self.MessageChain(*messages, bot: nil)
    MessageChain.make(*messages, bot: bot)
  end
end
