# frozen_string_literal: true

module Rubirai
  class Group
    attr_reader :id, :name, :permission

    # @param hash [Hash{String => Object}]
    def initialize(hash)
      hash = hash.stringify_keys
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
