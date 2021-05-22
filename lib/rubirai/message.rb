# frozen_string_literal: true

require 'rubirai/messages/message'
require 'rubirai/messages/message_chain'

module Rubirai
  # Form a message chain from a message or messages
  #
  # @param msgs [Array<Rubirai::Message, Hash, Object>] the messages
  # @param bot [Rubirai::Bot, nil]
  # @return [Rubirai::MessageChain] the message chain
  def self.msg_to_chain(*msgs, bot: nil)
    result = []
    msgs.map { |msg| to_message(msg, bot) }.each do |msg|
      if !result.empty? && result[-1].is_a?(PlainMessage) && msg.is_a?(PlainMessage)
        result[-1] = PlainMessage.from(text: result[-1].text + msg.text, bot: bot)
      else
        result.append msg
      end
    end
    MessageChain.make(*result, bot: bot)
  end

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

  private_class_method :to_message

  # Section of Bot about messages
  class Bot
    # Send temp message
    #
    # @param target_qq [Integer] target qq id
    # @param group_id [Integer] group id
    # @param msgs [Array<Rubirai::Message, Hash, String, Object>] messages to form a chain, can be any type
    # @return [Integer] message id
    def send_temp_msg(target_qq, group_id, *msgs)
      chain = Rubirai.msg_to_chain(*msgs, bot: self)
      resp = call :post, '/sendTempMessage', json: {
        sessionKey: @session,
        qq: target_qq,
        group: group_id,
        messageChain: chain.to_a
      }
      resp['messageId']
    end

    def send_msg(type, target_id, *msgs)
      self.class.ensure_type_in type, 'group', 'friend'
      chain = Rubirai.msg_to_chain(*msgs, bot: self)
      resp = call :post, "/send#{type.to_s.snake_to_camel}Message", json: {
        sessionKey: @session,
        target: target_id,
        messageChain: chain.to_a
      }
      resp['messageId']
    end

    def send_friend_msg(target_qq, *msgs)
      send_msg :friend, target_qq, *msgs
    end

    def send_group_msg(target_group_id, *msgs)
      send_msg :group, target_group_id, *msgs
    end

    def recall(msg_id)
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
end
