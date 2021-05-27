# frozen_string_literal: true

require 'rubirai/events/event'

module Rubirai
  class RequestEvent < Event
    # @!attribute [r] event_id
    #   @return [Integer] the event id
    # @!attribute [r] from_id
    #   @return [Integer] the id of the sender of the request
    # @!attribute [r] group_id
    #   @return [Integer] the group where the request is from. 0 if not from group
    # @!attribute [r] nick
    #   @return [String] the nickname of the sender of the request
    # @!attribute [r] message
    #   @return [String] the message from the sender
    set_event nil, :event_id, :from_id, :group_id, :nick, :message
  end

  class NewFriendRequestEvent < RequestEvent
    set_event :NewFriendRequestEvent
  end

  class JoinGroupRequestEvent < RequestEvent
    # @!attribute [r] group_name
    #   @return [String] the group name
    set_event :MemberJoinRequestEvent, :group_name
  end

  class BotInvitedToGroupEvent < RequestEvent
    # @!attribute [r] group_name
    #   @return [String] the group name
    set_event :BotInvitedJoinGroupRequestEvent, :group_name
  end
end
