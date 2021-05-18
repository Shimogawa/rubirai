# frozen_string_literal: true

require 'rubirai/messages/message'
require 'rubirai/messages/message_chain'

module Rubirai
  # Section of Bot about messages
  class Bot
    # Form a message chain from a message or messages
    #
    # @param msgs [Array<Rubirai::Message, Hash, Object>] the messages
    # @return [Rubirai::MessageChain] the message chain
    def self.msg_to_chain(*msgs)
      msgs = msgs.map(&:to_message)
      MessageChain.make(*msgs)
    end

    def send_temp_msg(target_qq, group_id, msg)
      chain = self.class.msg_to_chain msg
      resp = call :post, '/sendTempMessage', json: {
        sessionKey: @session,
        qq: target_qq,
        group: group_id,
        messageChain: chain.to_a
      }
      resp['messageId']
    end

    def send_msg(type, target_id, msg)
      self.class.ensure_type_in type, 'group', 'friend'
      chain = self.class.msg_to_chain msg
      resp = call :post, "/send#{type.to_s.snake_to_camel}Message", json: {
        sessionKey: @session,
        target: target_id,
        messageChain: chain.to_a
      }
      resp['messageId']
    end

    def send_friend_msg(target_qq, msg)
      send_msg :friend, target_qq, msg
    end

    def send_group_msg(target_group_id, msg)
      send_msg :group, target_group_id, msg
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

    # Objects to {Rubirai::Message}
    #
    # @param msg [Rubirai::Message, Hash, Object] the object to transform to a message
    # @return [Rubirai::Message] the message
    def self.to_message(msg)
      # noinspection RubyYardReturnMatch
      case msg
      when Message
        msg
      when Hash
        Message.build_from(msg)
      else
        PlainMessage.from(msg.to_s)
      end
    end

    private_class_method :to_message
  end
end
