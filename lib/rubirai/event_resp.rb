# frozen_string_literal: true

require 'rubirai/events/event'

module Rubirai
  # Operations for responding to friend requests.
  # Only use the values defined in this module to respond to friend requests.
  module FriendRequestOperation
    # Approve the request
    APPROVE = 0

    # Deny the request
    DENY = 1

    # Deny and blacklist the sender of the request
    DENY_AND_BLACKLIST = 2
  end

  # Operations for responding to group join requests.
  # Only use the values defined in this module to respond to group join requests.
  module JoinGroupRequestOperation
    # Approve the request
    APPROVE = 0

    # Deny the request
    DENY = 1

    # Ignore the request
    IGNORE = 2

    # Deny and blacklist the sender of the request
    DENY_AND_BLACKLIST = 3

    # Ignore and blacklist the sender of the request
    IGNORE_AND_BLACKLIST = 4
  end

  # Operations for responding to group invite requests.
  # Only use the values defined in this module to respond to group invite requests.
  module GroupInviteRequestOperation
    # Approve the request
    APPROVE = 0

    # Deny the request
    DENY = 1
  end

  class Bot
    # Respond to new friend request (raw)
    #
    # @param event_id [Integer] the event id
    # @param from_id [Integer] id of the requester
    # @param operation [Integer] see {FriendRequestOperation}.
    # @param group_id [Integer] the group where the request is from. 0 if not from group.
    # @param message [String] the message to reply
    # @return [void]
    def respond_to_new_friend_request(event_id, from_id, operation, group_id = 0, message = '')
      call :post, '/resp/newFriendRequestEvent', json: {
        sessionKey: @session,
        eventId: event_id,
        fromId: from_id,
        groupId: group_id,
        operate: operation,
        message: message
      }
      nil
    end

    # Respond to join group request (raw)
    #
    # @param event_id [Integer] the event id
    # @param from_id [Integer] id of the requester
    # @param operation [Integer] see {JoinGroupRequestOperation}
    # @param group_id [Integer] the group where the request is from. 0 if not from group.
    # @param message [String] the message to reply
    # @return [void]
    def respond_to_member_join(event_id, from_id, group_id, operation, message = '')
      call :post, '/resp/memberJoinRequestEvent', json: {
        sessionKey: @session,
        eventId: event_id,
        fromId: from_id,
        groupId: group_id,
        operate: operation,
        message: message
      }
      nil
    end

    # Respond to group invitations (raw)
    #
    # @param event_id [Integer] the event id
    # @param from_id [Integer] id of the sender
    # @param group_id [Integer] the group id
    # @param operation [Integer] see {GroupInviteRequestOperation}
    # @param message [String] the message to reply
    # @return [void]
    def respond_to_group_invite(event_id, from_id, group_id, operation, message = '')
      call :post, '/resp/botInvitedJoinGroupRequestEvent', json: {
        sessionKey: @session,
        eventId: event_id,
        fromId: from_id,
        groupId: group_id,
        operate: operation,
        message: message
      }
      nil
    end
  end

  class RequestEvent
    # @abstract
    def respond(operation, message)
      raise NotImplementedError
    end
  end

  class NewFriendRequestEvent
    # Respond to the friend request.
    #
    # @param operation [Integer] see {FriendRequestOperation}
    # @param message [String] the message to reply
    # @return [void]
    def respond(operation, message = '')
      @bot.respond_to_new_friend_request @event_id, @from_id, operation, @group_id, message
    end
  end

  class JoinGroupRequestEvent
    # Respond to the friend request.
    #
    # @param operation [Integer] see {JoinGroupRequestOperation}
    # @param message [String] the message to reply
    # @return [void]
    def respond(operation, message = '')
      @bot.respond_to_member_join @event_id, @from_id, @group_id, operation, message
    end
  end

  class BotInvitedToGroupEvent
    # Respond to the group invitation.
    #
    # @param operation [Integer] see {GroupInviteRequestOperation}
    # @param message [String] the message to reply
    # @return [void]
    def respond(operation, message = '')
      @bot.respond_to_group_invite @event_id, @from_id, @group_id, operation, message
    end
  end
end
