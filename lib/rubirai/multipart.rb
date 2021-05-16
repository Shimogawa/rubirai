# frozen_string_literal: true

module Rubirai
  class Bot
    # Uploads an image to QQ server
    # @return [Hash] hash string keys are: `{ imageId, url, path }`
    def upload_image(path_or_io, type = :friend)
      ensure_type_in type, 'friend', 'group', 'temp'
      call :post, '/uploadImage', form: {
        sessionKey: @session,
        type: type.to_s.downcase,
        img: HTTP::FormData::File.new(path_or_io)
      }
    end

    # Uploads a voice file to QQ server
    # Only group uploads available currently.
    # @param path_or_io [String, Pathname, IO] path to voice file
    # @return [Hash] hash string keys are: `{ voiceId, url, path }`
    def upload_voice(path_or_io)
      call :post, '/uploadVoice', form: {
        sessionKey: @session,
        type: 'group',
        img: HTTP::FormData::File.new(path_or_io)
      }
    end

    # Uploads a file to a group (currently only groups supported)
    # @param path_or_io [String, Pathname, IO] path to file
    # @param target [Integer] group id
    # @param group_path [String] path to file in group files
    # @return [String] the string id of the mirai file
    def upload_file_and_send(path_or_io, target, group_path)
      res = call :post, '/uploadFileAndSend', form: {
        sessionKey: @session,
        type: 'Group',
        target: target,
        path: group_path,
        file: HTTP::FormData::File.new(path_or_io)
      }
      res['id']
    end
  end
end
