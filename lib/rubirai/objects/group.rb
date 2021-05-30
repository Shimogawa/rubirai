# frozen_string_literal: true

module Rubirai
  # The group
  #
  # @!attribute [r] bot
  #   @return [Bot] the bot
  # @!attribute [r] id
  #   @return [Integer] group id
  # @!attribute [r] name
  #   @return [String] group name
  # @!attribute [r] permission
  #   @return [String] the group permission of the bot. See {Permission}
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

    # Group permissions
    class Permission
      # Owner
      OWNER = 'OWNER'

      # Administrator
      ADMINISTRATOR = 'ADMINISTRATOR'

      # Member
      MEMBER = 'MEMBER'
    end
  end
end
