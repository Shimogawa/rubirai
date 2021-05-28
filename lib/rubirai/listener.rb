# frozen_string_literal: true

require 'concurrent'
require 'rubirai/events/rubirai_events'

module Rubirai
  class Bot
    def start_listen(interval, is_blocking: false, ignore_error: false)
      raise RubiraiError, 'listener is already running' if @listener&.running?
      @listener_stop_event = Concurrent::Event.new if is_blocking
      bot = self
      @listener = Concurrent::TimerTask.new(execution_interval: interval) do
        loop do
          events = fetch_message
          events.each do |e|
            @listener_funcs.each { |f| f.call e }
          rescue RuntimeError => e
            @listener_funcs.each { |f| f.call RubiraiErrorEvent.new(e, bot) unless ignore_error }
          end
          break if events.length < 10
        rescue RuntimeError => e
          @listener_funcs.each { |f| f.call RubiraiErrorEvent.new(e, bot) unless ignore_error }
          break
        end
      end
      @listener.execute
      @listener_stop_event.wait if is_blocking
    end

    def add_listener(&listener_block)
      @listener_funcs << listener_block
    end

    def clear_listener
      @listener_funcs.clear
    end

    def stop_listen
      @listener.shutdown
      @listener_stop_event&.set
      @listener_stop_event = nil
    end
  end
end
