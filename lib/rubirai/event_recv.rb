# frozen_string_literal: true

require 'rubirai/events/event'

module Rubirai
  # Section of Bot about event receiving
  class Bot
    # Fetch `count` number of oldest events.
    # @param count [Integer] the number of events to fetch
    # @return [Array<Event>] the event objects. The keys are in
    #         snake case.
    def fetch_message(count = 10)
      get_events '/fetchMessage', count
    end

    def fetch_latest_message(count = 10)
      get_events '/fetchLatestMessage', count
    end

    def peek_message(count = 10)
      get_events '/peekMessage', count
    end

    def peek_latest_message(count = 10)
      get_events '/peekLatestMessage', count
    end

    def message_from_id(msg_id)
      resp = call :get, '/messageFromId', params: {
        sessionKey: @session,
        id: msg_id
      }
      Event.parse resp['data']
    end

    def count_cached_message
      resp = call :get, '/countMessage', param: {
        sessionKey: @session
      }
      resp['data']
    end

    private

    def get_events(path, count)
      resp = call :get, path, params: {
        sessionKey: @session,
        count: count
      }
      resp['data'].map do |event|
        Event.parse event
      end
    end
  end
end
