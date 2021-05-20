# frozen_string_literal: true

require_relative 'group'
require 'rubirai/errors'

module Rubirai
  class User
    attr_reader :bot, :id, :name, :remark

    def initialize(hash, bot = nil)
      hash = hash.stringify_keys
      @bot = bot
      @id = hash['id']
      @name = hash['name'] || hash['nickname']
      @remark = hash['remark']
    end
  end

  class GroupUser < User
    attr_reader :member_name, :permission, :group

    def initialize(hash, bot = nil)
      raise(RubiraiError, 'not a group user') unless hash.key? 'group'
      super(hash, bot)
      @member_name = hash['memberName']
      @permission = hash['permission']
      @group = Group.new(hash['group'], bot)
    end
  end
end
