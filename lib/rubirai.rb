# frozen_string_literal: true

require 'rubirai/errors'
require 'rubirai/utils'

# Rubirai is a library for connecting Mirai http api.
module Rubirai
  require 'http'

  # Bot represents a QQ bot at mirai side. All functions are API calls to the http plugin.
  class Bot
    # @!attribute [r] base_uri
    #   @return [String] the base uri of mirai-api-http which the bot will send messages to
    # @!attribute [r] session
    #   @return [String] the session key
    # @!attribute [r] qq
    #   @return [String, Integer] the qq of the bot
    attr_reader :base_uri, :session, :qq

    # Initializes the bot
    #
    # @param host [String] the host (IP or domain)
    # @param port [String, Integer, nil] the port number (default is 80 for http)
    def initialize(host, port = nil)
      @base_uri = "http://#{host}#{":#{port}" if port}"
    end

    def gen_uri(path)
      URI.join(base_uri, path)
    end

    private

    def call(method, path, **kwargs)
      return unless %i[get post].include?(method) && HTTP.respond_to?(method)

      resp = HTTP.send method, gen_uri(path), kwargs
      raise(HttpResponseError, resp.code) unless resp.status.success?

      body = JSON.parse(resp.body)
      if (body.is_a? Hash) && (body.include? 'code') && (body['code'] != 0)
        raise MiraiError.new(body['code'], body['msg'] || body['errorMessage'])
      end

      body
    end

    def self.ensure_type_in(type, *types)
      types = types.map { |x| x.to_s.downcase }
      type.to_s.downcase.must_be_one_of! types, RubiraiError, "not valid type: should be one of #{types}"
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
