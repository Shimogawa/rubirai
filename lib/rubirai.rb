# Copyright 2021 Rebuild.
#
# 此源代码的使用受 GNU AFFERO GENERAL PUBLIC LICENSE version 3 许可证的约束, 可以在以下链接找到该许可证.
# Use of this source code is governed by the GNU AGPLv3 license that can be found through the following link.
#
# https://github.com/Shimogawa/rubirai/blob/master/LICENSE
#

# frozen_string_literal: true

require 'rubirai/errors'
require 'rubirai/utils'

# Rubirai is a library for connecting Mirai http api.
module Rubirai
  require 'http'

  # Bot represents a QQ bot at mirai side. All functions are API calls to the http plugin.
  #
  # @!attribute [r] base_uri
  #   @return [String] the base uri of mirai-api-http which the bot will send messages to
  # @!attribute [r] session
  #   @return [String] the session key
  # @!attribute [r] qq
  #   @return [String, Integer] the qq of the bot
  class Bot
    attr_reader :base_uri, :session, :qq

    alias id qq

    # Initializes the bot
    #
    # @param host [String] the host (IP or domain)
    # @param port [String, Integer, nil] the port number (default is 80 for http)
    def initialize(host, port = nil)
      @base_uri = "http://#{host}#{":#{port}" if port}"
      @listener_funcs = []
    end

    # @private
    def gen_uri(path)
      URI.join(base_uri, path)
    end

    # @private
    def self.ensure_type_in(type, *types)
      types = types.map { |x| x.to_s.downcase }
      type.to_s.downcase.must_be_one_of! types, RubiraiError, "not valid type: should be one of #{types}"
    end

    private

    def call(method, path, **kwargs)
      return unless %i[get post].include?(method) && HTTP.respond_to?(method)

      resp = HTTP.send method, gen_uri(path), kwargs
      raise(HttpResponseError, resp.code) unless resp.status.success?

      body = JSON.parse(resp.body)
      if (body.is_a? Hash) && (body.include? 'code') && (body['code'] != 0)
        raise MiraiError.new(body['code'], body['msg'])
      end

      body
    end
  end
end

require 'rubirai/auth'
require 'rubirai/event_recv'
require 'rubirai/listener'
require 'rubirai/listing'
require 'rubirai/management'
require 'rubirai/message'
require 'rubirai/multipart'
require 'rubirai/plugin_info'
require 'rubirai/retcode'
require 'rubirai/session'
require 'rubirai/version'
