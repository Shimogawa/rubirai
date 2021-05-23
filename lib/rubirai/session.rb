# frozen_string_literal: true

module Rubirai
  # Section of Bot about session
  class Bot
    def get_session_cfg
      call :get, '/config', params: {
        sessionKey: @session
      }
    end

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
