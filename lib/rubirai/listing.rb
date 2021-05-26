# frozen_string_literal: true

require 'rubirai/objects/user'
require 'rubirai/objects/group'

module Rubirai
  class Bot
    # Get friend list of the bot
    # @return [Array<User>] list of friends
    def friend_list
      resp = call :get, '/friendList', params: {
        sessionKey: @session
      }
      resp.map { |friend| User.new(friend, self) }
    end

    # Get group list of the bot
    # @return [Array<Group>] list of groups
    def group_list
      resp = call :get, '/groupList', params: {
        sessionKey: @session
      }
      resp.map { |group| Group.new(group, self) }
    end

    # Get member list of a group
    # @param group_id [Integer, String] group id
    # @return [Array<GroupUser>] list of members
    def member_list(group_id)
      resp = call :get, '/memberList', params: {
        sessionKey: @session,
        target: group_id
      }
      resp.map { |member| GroupUser.new(member, self) }
    end
  end
end
