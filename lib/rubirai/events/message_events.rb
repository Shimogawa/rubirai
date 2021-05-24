# frozen_string_literal: true

require 'rubirai/events/event'

module Rubirai
  # @abstract
  class MessageEvent < Event
    # @!attribute [r] message_chain
    #   @return [MessageChain] the message chain
    # @!attribute [r] sender
    #   @return [Integer] the sender id
    set_event nil, :message_chain, :sender
  end

  class FriendMessageEvent < MessageEvent
    # @!method initialize(hash, bot = nil)
    #   @param hash [Hash]
    #   @param bot [Rubirai::Bot]
    set_event :FriendMessage
  end

  class GroupMessageEvent < MessageEvent
    # @!method initialize(hash, bot = nil)
    #   @param hash [Hash]
    #   @param bot [Rubirai::Bot]
    set_event :GroupMessage
  end

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

  class FriendRecallEvent < RecallEvent
    # @!method initialize(hash, bot = nil)
    #   @param hash [Hash]
    #   @param bot [Rubirai::Bot]
    # @!attribute [r] operator
    #   @return [Integer] the operator id
    set_event :FriendRecallEvent, :operator
  end
end
