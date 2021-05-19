# frozen_string_literal: true

require 'concurrent'
require 'rubirai/events/bot_events'

module Rubirai
  # Section of Bot about event listening
  class Bot
    def start_listener(interval, is_blocking: false, &block)
      raise RubiraiError, 'listener is already running' if @listener.running?
      @listener_stop_event = Concurrent::Event.new if is_blocking
      @listener = Concurrent::TimerTask(execution_interval: interval) do
        loop do
          events = fetch_message
          events.each { |e| block.call(e) }
          break if events.length < 10
        rescue RuntimeError => e
          block.call(RubiraiErrorEvent.new(e))
          break
        end
      end
      @listener.execute
      @listener_stop_event.wait if is_blocking
    end

    def stop_listener
      @listener.shutdown
      @listener_stop_event&.set
      @listener_stop_event = nil
    end
  end
end
