# frozen_string_literal: true

require 'rubirai/events/event'

module Rubirai
  # The base class for message events
  # @abstract
  class MessageEvent < Event
    # @!attribute [r] message_chain
    #   @return [MessageChain] the message chain
    # @!attribute [r] sender
    #   @return [User] the sender
    set_event nil, :message_chain, :sender
  end

  # Friend message event
  class FriendMessageEvent < MessageEvent
    # @!method initialize(hash, boxt = nil)
    #   @param hash [Hash]
    #   @param bot [Rubirai::Bot]
    # @!attribute [r] sender
    #   @return [User] the sender
    set_event :FriendMessage
  end

  # Group message event
  class GroupMessageEvent < MessageEvent
    # @!method initialize(hash, bot = nil)
    #   @param hash [Hash]
    #   @param bot [Rubirai::Bot]
    # @!attribute [r] sender
    #   @return [GroupUser] the sender
    set_event :GroupMessage
  end

  # Temp message event
  class TempMessageEvent < MessageEvent
    # @!method initialize(hash, bot = nil)
    #   @param hash [Hash]
    #   @param bot [Rubirai::Bot]
    # @!attribute [r] sender
    #   @return [GroupUser] the sender
    set_event :TempMessage
  end

  # The base class for recall events
  # @abstract
  class RecallEvent < Event
    # @!attribute [r] author_id
    #   @return [Integer] the author's id
    # @!attribute [r] message_id
    #   @return [Integer] the message id
    # @!attribute [r] time
    #   @return [Integer] the time the message is sent
    set_event nil, :author_id, :message_id, :time
  end

  # Group recall event
  class GroupRecallEvent < RecallEvent
    # @!method initialize(hash, bot = nil)
    #   @param hash [Hash]
    #   @param bot [Rubirai::Bot]
    # @!attribute [r] group
    #   @return [Group] the group
    # @!attribute [r] operator
    #   @return [GroupUser] the operator
    set_event :GroupRecallEvent, :group, :operator
  end

  # Friend recall event
  class FriendRecallEvent < RecallEvent
    # @!method initialize(hash, bot = nil)
    #   @param hash [Hash]
    #   @param bot [Rubirai::Bot]
    # @!attribute [r] operator
    #   @return [Integer] the operator id
    set_event :FriendRecallEvent, :operator
  end
end
