# frozen_string_literal: true

require 'rubirai/messages/message'
require 'rubirai/messages/message_chain'

module Rubirai
  # Section of Bot about messages
  class Bot
    def msg_to_chain(msg)
      case msg
      when Message
        make_chain msg
      when MessageChain
        msg
      when Hash
        make_chain Message.build_from(msg)
      when Array
        make_chain(*msg)
      else
        make_chain PlainMessage.from(msg.to_s)
      end
    end

    def send_temp_msg(target_qq, group_id, msg)
      chain = msg_to_chain msg
      resp = call :post, '/sendTempMessage', json: {
        sessionKey: @session,
        qq: target_qq,
        group: group_id,
        messageChain: chain.to_a
      }
      resp['messageId']
    end

    def send_msg(type, target_id, msg)
      ensure_type_in type, 'group', 'friend'
      chain = msg_to_chain msg
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

    private

    def make_chain(*msgs)
      MessageChain.make msgs
    end
  end
end
