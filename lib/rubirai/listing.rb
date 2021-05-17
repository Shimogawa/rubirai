# frozen_string_literal: true

require 'rubirai/objects/user'
require 'rubirai/objects/group'

module Rubirai
  # Section of Bot about member/group listings
  class Bot
    def friend_list
      resp = call :get, '/friendList', params: {
        sessionKey: @session
      }
      resp.map { |friend| User.new(**friend) }
    end

    def group_list
      resp = call :get, '/groupList', params: {
        sessionKey: @session
      }
      resp.map { |group| Group.new(**group) }
    end

    def member_list(group_id)
      resp = call :get, '/memberList', params: {
        sessionKey: @session,
        target: group_id
      }
      resp.map { |member| GroupUser.new(**member) }
    end
  end
end
