# frozen_string_literal: true

require 'rubirai/events/event'

module Rubirai
  class RubiraiErrorEvent < Event
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
