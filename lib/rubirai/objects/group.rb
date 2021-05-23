# frozen_string_literal: true

module Rubirai
  class Group
    attr_reader :bot, :id, :name, :permission

    # @param hash [Hash{String => Object}]
    # @param bot [Rubirai::Bot, nil]
    def initialize(hash, bot = nil)
      hash = hash.stringify_keys
      @bot = bot
      @id = hash['id']
      @name = hash['name']
      @permission = hash['permission']
    end

    class Permission
      OWNER = 'OWNER'
      ADMINISTRATOR = 'ADMINISTRATOR'
      MEMBER = 'MEMBER'
    end
  end
end
