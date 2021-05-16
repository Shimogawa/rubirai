# frozen_string_literal: true

require 'rubirai/utils'

module Rubirai
  class MessageChain
    attr_reader :sender_id, :send_time, :messages, :read_only

    def self.make(*messages, sender_id: nil)
      res = new
      res.sender_id = sender_id if sender_id
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
      msg.must_be! [Message, Hash], RubiraiError, 'msg must be a message or hash'

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
end
