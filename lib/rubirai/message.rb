# frozen_string_literal: true

require 'rubirai/messages/message'
require 'rubirai/messages/message_chain'

module Rubirai
  class Bot
    # Send temp message
    #
    # @param target_qq [Integer] target qq id
    # @param group_id [Integer] group id
    # @param msgs [Array<Rubirai::Message, Hash, String, Object>] messages to form a chain, can be any type
    # @param quote [NilClass, Integer] the message id to quote, nil for not quote
    # @return [Integer] message id
    def send_temp_msg(target_qq, group_id, *msgs, quote: nil)
      chain = Rubirai::MessageChain.make(*msgs, bot: self)
      resp = call :post, '/sendTempMessage', json: {
        sessionKey: @session,
        qq: target_qq.to_i,
        group: group_id.to_i,
        quote: quote,
        messageChain: chain.to_a
      }.compact
      resp['messageId']
    end

    # Send friend or group message
    #
    # @param type [Symbol, String] options: [group, friend]
    # @param target_id [Integer] target qq/group id
    # @param msgs [Array<Rubirai::Message, Hash, String, Object>] messages to form a chain, can be any type
    # @param quote [NilClass, Integer] the message id to quote, nil for not quote
    # @return [Integer] message id
    def send_msg(type, target_id, *msgs, quote: nil)
      self.class.ensure_type_in type, 'group', 'friend'
      chain = Rubirai::MessageChain.make(*msgs, bot: self)
      resp = call :post, "/send#{type.to_s.snake_to_camel}Message", json: {
        sessionKey: @session,
        target: target_id.to_i,
        quote: quote,
        messageChain: chain.to_a
      }.compact
      resp['messageId']
    end

    # Send friend message
    #
    # @param target_qq [Integer] target qq id
    # @param msgs [Array<Rubirai::Message, Hash, String, Object>] messages to form a chain, can be any type
    # @param quote [NilClass, Integer] the message id to quote, nil for not quote
    # @return [Integer] message id
    def send_friend_msg(target_qq, *msgs, quote: nil)
      send_msg :friend, target_qq, *msgs, quote: quote
    end

    # Send group message
    #
    # @param target_group_id [Integer] group id
    # @param msgs [Array<Rubirai::Message, Hash, String, Object>] messages to form a chain, can be any type
    # @param quote [NilClass, Integer] the message id to quote, nil for not quote
    # @return [Integer] message id
    def send_group_msg(target_group_id, *msgs, quote: nil)
      send_msg :group, target_group_id, *msgs, quote: quote
    end

    # Recall a message
    #
    # @param msg_id [Integer, Rubirai::MessageChain] message id
    # @return [void]
    def recall(msg_id)
      msg_id = msg_id.id if msg_id.is_a? Rubirai::MessageChain
      call :post, '/recall', json: {
        sessionKey: @session,
        target: msg_id
      }
      nil
    end

    # Send image messages
    #
    # @param urls [Array<String>] the urls of the images
    # @param kwargs [Hash] keys are one of [target, qq, group].
    # @return [Array<String>] the image ids
    def send_image_msg(urls, **kwargs)
      urls.must_be! Array
      urls.each do |url|
        url.must_be! String
      end
      valid = %w[target qq group]
      res = {
        sessionKey: @session,
        urls: urls
      }
      kwargs.each do |k, v|
        res[k.to_s.downcase.to_sym] = v if valid.include? k.to_s.downcase
      end
      call :post, '/sendImageMessage', json: res
    end

    # Send nudge
    #
    # @param target_id [Integer] target id
    # @param subject_id [Integer] the id of the place where the nudge will be seen.
    #                   Should be a group id or a friend's id
    # @param kind [String, Symbol] options: `[Group, Friend]`
    # @return [void]
    def send_nudge(target_id, subject_id, kind)
      kind.to_s.downcase.must_be_one_of! %w[group friend], RubiraiError, 'kind must be one of group or friend'
      call :post, '/sendNudge', json: {
        sessionKey: @session,
        target: target_id,
        subject: subject_id,
        kind: kind.to_s.capitalize
      }
      nil
    end
  end

  class MessageEvent
    # Respond to a message event
    #
    # @param msgs [Array<Rubirai::Message, Hash, String, Object>] messages to form a chain
    # @param quote [Boolean] if to quote the original message
    # @return [Integer] message id
    def respond(*msgs, quote: false)
      check_bot
      quote_id = quote ? (@message_chain.id || nil) : nil
      case self
      when FriendMessageEvent
        @bot.send_friend_msg(@sender.id, *msgs, quote: quote_id)
      when GroupMessageEvent
        @bot.send_group_msg(@sender.group.id, *msgs, quote: quote_id)
      when TempMessageEvent
        @bot.send_temp_msg(@sender.id, @sender.group.id, *msgs, quote: quote_id)
      else
        raise 'undefined error'
      end
    end

    private

    def check_bot
      raise RubiraiError, 'no bot found in event' unless @bot
    end
  end
end
