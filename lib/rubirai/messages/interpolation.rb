# frozen_string_literal: true

require 'rubirai/utils'

module Rubirai
  # @!attribute [r] has_interpolation
  #   @return [Boolean] if this message chain has interpolation called by {#interpolated_str}
  class MessageChain
    attr_reader :has_interpolation

    # Convert the message chain to an interpolated string.
    #
    # @return [String]
    def interpolated_str
      return @interpolated_str if @has_interpolation
      @interpolated_str = _gen_interp_str
      @has_interpolation = true
      @interpolated_str
    end

    # Get the interpolated object by given id
    #
    # @param obj_id [String] the object id
    # @return [Message, nil] the message. `nil` if `obj_id` is malformed or not found.
    def get_object(obj_id)
      _get_object(obj_id)
    end

    # Get a new chain from interpolated string generated from the original message chain.
    # The given interpolated string can be a substring of original one so that elements
    # can be extracted easily.
    #
    # @param str [String] the interpolated string
    # @return [MessageChain] the message chain constructed
    def chain_from_interpolated(str)
      _interpolate_with_objects(str)
    end

    private

    OBJ_INTERP_CHAR = '%'
    OBJ_INTERP_LEN = 6

    def _gen_interp_str
      result = +''
      @messages.each do |msg|
        result << case msg
                  when PlainMessage
                    _transform_plain_txt(msg.text)
                  else
                    _transform_object(msg)
                  end
      end
      result
    end

    def _transform_plain_txt(str)
      str.gsub(OBJ_INTERP_CHAR, OBJ_INTERP_CHAR * 2)
    end

    def _transform_object(obj)
      obj_id = Utils.random_str(OBJ_INTERP_LEN)
      obj_id = Utils.random_str(OBJ_INTERP_LEN) while @ipl_objs_map.include?(obj_id)
      @ipl_objs_map[obj_id] = obj
      "#{OBJ_INTERP_CHAR}#{obj_id}#{OBJ_INTERP_CHAR}"
    end

    def _get_object(obj_id)
      return nil if obj_id.length != OBJ_INTERP_LEN && obj_id.length != (OBJ_INTERP_LEN + 2)
      return @ipl_objs_map[obj_id] if obj_id.length == OBJ_INTERP_LEN
      return nil if obj_id[0] != OBJ_INTERP_CHAR || obj_id[-1] != OBJ_INTERP_CHAR

      @ipl_objs_map[obj_id[1...-1]]
    end

    # @private
    # @param str [String]
    def _interpolate_with_objects(str)
      sb = +''
      result = MessageChain.new(bot)
      i = 0
      while i < str.length
        if i == str.length - 1
          sb << str[i]
          break
        end

        if str[i] != OBJ_INTERP_CHAR
          sb << str[i]
          i += 1
          next
        end

        if str[i + 1] == OBJ_INTERP_CHAR
          sb << OBJ_INTERP_CHAR
          i += 1
        else
          result.append PlainMessage.from(text: sb) unless sb.empty?
          sb = str[i...i + OBJ_INTERP_LEN + 2]
          obj = _get_object(sb)
          i += OBJ_INTERP_LEN + 1
          unless obj.nil?
            result.append obj
            sb = +''
          end
        end

        i += 1
      end

      result.append PlainMessage.from(text: sb) unless sb.nil? || sb.empty?
      result
    end
  end
end
