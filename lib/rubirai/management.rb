# frozen_string_literal: true

require 'rubirai/objects/info'

module Rubirai
  # Section of Bot about group management
  class Bot
    # Mute a group member
    #
    # @param group_id [Integer] group id
    # @param member_id [Integer] member id
    # @param time [Integer] the mute time
    def mute(group_id, member_id, time = 0)
      call :post, '/mute', json: {
        sessionKey: @session,
        target: group_id,
        memberId: member_id,
        time: time
      }
      nil
    end

    # Unmute a group member
    #
    # @param group_id [Integer] group id
    # @param member_id [Integer] member id
    # @return [void]
    def unmute(group_id, member_id)
      call :post, '/unmute', json: {
        sessionKey: @session,
        target: group_id,
        memberId: member_id
      }
      nil
    end

    # Kick a member from a group
    #
    # @param group_id [Integer] group id
    # @param member_id [Integer] member id
    # @param msg [String, nil] the message for the kicked
    # @return [void]
    def kick(group_id, member_id, msg = nil)
      json = {
        sessionKey: @session,
        target: group_id,
        memberId: member_id
      }
      json[:msg] = msg if msg
      call :post, '/kick', json: json
      nil
    end

    # Quit a group
    #
    # @param group_id [Integer] group id
    # @return [void]
    def quit(group_id)
      call :post, '/quit', json: {
        sessionKey: @session,
        target: group_id
      }
      nil
    end

    def mute_all(group_id)
      call :post, '/muteAll', json: {
        sessionKey: @session,
        target: group_id
      }
      nil
    end

    def unmute_all(group_id)
      call :post, '/unmuteAll', json: {
        sessionKey: @session,
        target: group_id
      }
      nil
    end

    def get_group_config(group_id)
      resp = call :get, '/groupConfig', params: {
        sessionKey: @session,
        target: group_id
      }
      GroupConfig.new resp
    end

    # Set group config
    #
    # @param group_id [Integer] group id
    # @param config [GroupConfig, Hash{String => Object}] the configuration
    # @return [void]
    def set_group_config(group_id, config)
      config.must_be! [GroupConfig, Hash], RubiraiError, 'must be GroupConfig or Hash'
      config.stringify_keys! if config.is_a? Hash
      config = config.to_h if config.is_a? GroupConfig
      call :post, '/groupConfig', json: {
        sessionKey: @session,
        target: group_id,
        config: config
      }
      nil
    end

    def get_member_info(group_id, member_id)
      resp = call :get, '/memberInfo', params: {
        sessionKey: @session,
        target: group_id,
        memberId: member_id
      }
      MemberInfo.new resp
    end

    def set_member_info(group_id, member_id, info)
      info.must_be! [MemberInfo, Hash], RubiraiError, 'must be MemberInfo or Hash'
      info.stringify_keys! if info.is_a? Hash
      info = info.to_h if info.is_a? MemberInfo
      call :post, '/memberInfo', json: {
        sessionKey: @session,
        target: group_id,
        memberId: member_id,
        info: info
      }
      nil
    end

    def get_group_file_list(group_id, dir = nil)
      resp = call :get, '/groupFileList', params: {
        sessionKey: @session,
        target: group_id,
        dir: dir
      }.compact
      resp.must_be! Array # assert resp is Array
      resp.map { |f| GroupFileSimple.new(f) }
    end

    # Get the info about a group file
    # @param group_id [Integer] the group id
    # @param file_id [String] the file id, e.g. `/xxx-xxx-xxx-xxx`
    def get_group_file_info(group_id, file_id)
      resp = call :get, '/groupFileInfo', params: {
        sessionKey: @session,
        target: group_id,
        id: file_id
      }
      GroupFile.new resp
    end

    def rename_group_file(group_id, file_id, new_name)
      call :post, '/groupFileRename', json: {
        sessionKey: @session,
        target: group_id,
        id: file_id,
        rename: new_name
      }
      nil
    end

    def group_mkdir(group_id, dir)
      call :post, '/groupMkdir', json: {
        sessionKey: @session,
        group: group_id,
        dir: dir
      }
      nil
    end

    def group_file_mv(group_id, file_id, path)
      call :post, '/groupFileMove', json: {
        sessionKey: @session,
        target: group_id,
        id: file_id,
        movePath: path
      }
      nil
    end

    def group_file_delete(group_id, file_id)
      call :post, '/groupFileDelete', json: {
        sessionKey: @session,
        target: group_id,
        id: file_id
      }
      nil
    end

    def group_set_essence(msg_id)
      call :post, '/setEssence', json: {
        sessionKey: @session,
        target: msg_id
      }
      nil
    end
  end
end
