# frozen_string_literal: true

module Rubirai
  class Bot
    # Get the config related to this session
    # @return [Hash{String => Object}] the config
    def get_session_cfg
      call :get, '/config', params: {
        sessionKey: @session
      }
    end

    # Set the config related to this session
    # @param cache_size [Integer, nil] the cache size
    # @param enable_websocket [Boolean, nil] if to enable websocket
    # @return [void]
    def set_session_cfg(cache_size: nil, enable_websocket: nil)
      call :post, '/config', json: {
        sessionKey: @session,
        cacheSize: cache_size,
        enableWebsocket: enable_websocket
      }.compact
      nil
    end
  end
end
