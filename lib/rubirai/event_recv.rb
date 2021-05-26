# frozen_string_literal: true

require 'rubirai/events/event'

module Rubirai
  class Bot
    # Fetch `count` number of oldest events.
    # @param count [Integer] the number of events to fetch
    # @return [Array<Event>] the event objects.
    def fetch_message(count = 10)
      get_events '/fetchMessage', count
    end

    alias fetch_messages fetch_message
    alias fetch_event fetch_message
    alias fetch_events fetch_message

    # Fetch `count` number of latest events.
    # @param count [Integer] the number of events to fetch
    # @return [Array<Event>] the event objects
    def fetch_latest_message(count = 10)
      get_events '/fetchLatestMessage', count
    end

    alias fetch_latest_messages fetch_latest_message
    alias fetch_latest_event fetch_latest_message
    alias fetch_latest_events fetch_latest_message

    # Peek `count` number of oldest events. (Will not delete from cache)
    # @param count [Integer] the number of events to peek
    # @return [Array<Event>] the event objects
    def peek_message(count = 10)
      get_events '/peekMessage', count
    end

    alias peek_messages peek_message
    alias peek_event peek_message
    alias peek_events peek_message

    # Peek `count` number of latest events. (Will not delete from cache)
    # @param count [Integer] the number of events to peek
    # @return [Array<Event>] the event objects
    def peek_latest_message(count = 10)
      get_events '/peekLatestMessage', count
    end

    alias peek_latest_messages peek_latest_message
    alias peek_latest_event peek_latest_message
    alias peek_latest_events peek_latest_message

    # Get a message event from message id
    # @param msg_id [Integer] message id
    # @return [Event] the event object
    def message_from_id(msg_id)
      resp = call :get, '/messageFromId', params: {
        sessionKey: @session,
        id: msg_id
      }
      Event.parse resp['data'], self
    end

    # Get the number of cached messages in mirai-http-api
    # @return [Integer] the number of cached messages
    def count_cached_message
      resp = call :get, '/countMessage', params: {
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
        Event.parse event, self
      end
    end
  end
end
