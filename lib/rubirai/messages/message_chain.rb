# frozen_string_literal: true

require 'rubirai/utils'

module Rubirai
  class MessageChain
    attr_reader :sender_id, :send_time, :messages, :read_only

    # Makes a message chain from a list of messages
    #
    # @param messages [Array<Rubirai::Message, Hash>] a list of messages
    # @param sender_id [Integer, nil]
    # @return [Rubirai::MessageChain] the message chain
    def self.make(*messages, sender_id: nil)
      res = new
      res.sender_id = sender_id if sender_id
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

    def internal_append(msg)
      msg.must_be! [Message, Hash], RubiraiError, 'msg must be a message or hash'

      if msg.is_a? Message
        @messages.append msg
        return self
      end
      @messages.append Message.build_from(msg)
      self
    end
  end
end
