# frozen_string_literal: true

module Rubirai
  class Group
    attr_reader :id, :name, :permission

    def initialize(**kwargs)
      kwargs = kwargs.stringify_keys
      @id = kwargs['id']
      @name = kwargs['name']
      @permission = kwargs['permission']
    end

    class Permission
      OWNER = 'OWNER'
      ADMINISTRATOR = 'ADMINISTRATOR'
      MEMBER = 'MEMBER'
    end
  end
end
