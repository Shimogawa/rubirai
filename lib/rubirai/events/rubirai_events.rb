# frozen_string_literal: true

require 'rubirai/events/event'

module Rubirai
  # Error events thrown when errors happened in event listeners
  class RubiraiErrorEvent < Event
    # @!attribute [r] err
    #   @return [RuntimeError] the error
    attr_reader :err

    # An error event just for internal use
    #
    # @param err [RuntimeError] the error object
    def initialize(err, bot = nil)
      super nil, bot
      @err = err
    end
  end
end
