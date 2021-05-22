# frozen_string_literal: true

require 'rubirai/utils'

module Rubirai
  class MessageChain
    attr_reader :bot, :sender_id, :send_time, :messages, :read_only

    # Makes a message chain from a list of messages
    #
    # @param messages [Array<Rubirai::Message, Rubirai::MessageChain, Hash>] a list of messages
    # @param sender_id [Integer, nil]
    # @param bot [Rubirai::Bot, nil]
    # @return [Rubirai::MessageChain] the message chain
    def self.make(*messages, sender_id: nil, bot: nil)
      res = new(bot, sender_id: sender_id)
      res.extend(*messages)
      res
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

    def concat(msg_chain)
      msg_chain.to_a.each do |msg|
        internal_append msg
      end
      self
    end

    # @param bot [Rubirai::Bot, nil]
    # @param source [Array, nil]
    # @param sender_id [Integer, nil]
    def initialize(bot = nil, source = nil, sender_id: nil)
      @bot = bot
      @sender_id = sender_id
      @messages = []
      return unless source
      raise(MiraiError, 'source is not array') unless source.class.is_a? Array
      raise(MiraiError, 'length is zero') if source.empty?

      if source[0].type == :Source
        @sender_id = source[0].id
        @send_time = source[0].time
        @messages = extend(*source.drop(1))
      else
        @messages = extend(*source)
      end
    end

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
end
