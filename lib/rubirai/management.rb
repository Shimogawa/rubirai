# frozen_string_literal: true

require 'rubirai/objects/group_info'

module Rubirai
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

    # Mute all in a group
    #
    # @param group_id [Integer] group id
    # @return [void]
    def mute_all(group_id)
      call :post, '/muteAll', json: {
        sessionKey: @session,
        target: group_id
      }
      nil
    end

    # Unmute all in a group
    #
    # @param group_id [Integer] group id
    # @return [void]
    def unmute_all(group_id)
      call :post, '/unmuteAll', json: {
        sessionKey: @session,
        target: group_id
      }
      nil
    end

    # Get group config
    #
    # @param group_id [Integer] group id
    # @return [GroupConfig] the config
    def get_group_config(group_id)
      resp = call :get, '/groupConfig', params: {
        sessionKey: @session,
        target: group_id
      }
      GroupConfig.new resp, self
    end

    # Set group config
    #
    # @param group_id [Integer] group id
    # @param config [GroupConfig, Hash{String, Symbol => Object}] the configuration. If given as
    #               a hash, then it should be exactly named the same as given in `mirai-api-http`
    #               docs.
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

    # Get member info
    #
    # @param group_id [Integer] group id
    # @param member_id [Integer] the member's qq id
    # @return [MemberInfo] the member's info
    def get_member_info(group_id, member_id)
      resp = call :get, '/memberInfo', params: {
        sessionKey: @session,
        target: group_id,
        memberId: member_id
      }
      MemberInfo.new resp, self
    end

    # Set member info
    #
    # @param group_id [Integer] group id
    # @param member_id [Integer] the member's qq id
    # @param info [MemberInfo, Hash{String,Symbol => Object}] the info to set. If given as
    #             a hash, then it should be exactly named the same as given in `mirai-api-http`
    #             docs.
    # @return [void]
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

    # Get the group files as a list
    #
    # @param group_id [Integer] the group id
    # @param dir [String, nil] the directory to get. If `nil`, then the root directory is asserted.
    # @return [Array<GroupFileSimple>] the list of files
    def get_group_file_list(group_id, dir = nil)
      resp = call :get, '/groupFileList', params: {
        sessionKey: @session,
        target: group_id,
        dir: dir
      }.compact
      resp.must_be! Array # assert resp is Array
      resp.map { |f| GroupFileSimple.new(f, self) }
    end

    # Get the info about a group file
    # @param group_id [Integer] the group id
    # @param file_or_id [GroupFileSimple, String] the file id, e.g. `/xxx-xxx-xxx-xxx`
    #
    # @return [GroupFile] the info about the file
    def get_group_file_info(group_id, file_or_id)
      file_or_id.must_be! [GroupFileSimple, String], RubiraiError, 'must be GroupFileSimple or String'
      raise RubiraiError, "#{file_or_id} is not a file" if file_or_id.is_a?(GroupFileSimple) && !file_or_id.is_file?
      id = file_or_id.is_a? String ? file_or_id : file_or_id.id

      resp = call :get, '/groupFileInfo', params: {
        sessionKey: @session,
        target: group_id,
        id: id
      }
      GroupFile.new resp, self
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
