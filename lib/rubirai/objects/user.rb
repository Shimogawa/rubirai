# frozen_string_literal: true

require_relative 'group'
require 'rubirai/errors'

module Rubirai
  class User
    attr_reader :id, :name, :remark

    def initialize(**kwargs)
      kwargs = kwargs.stringify_keys
      @id = kwargs['id']
      @name = kwargs['name'] || kwargs['nickname']
      @remark = kwargs['remark']
    end
  end

  class GroupUser < User
    attr_reader :member_name, :permission, :group

    def initialize(**kwargs)
      raise(RubiraiError, 'not a group user') unless kwargs.key? 'group'
      super(**kwargs)
      @member_name = kwargs['member_name']
      @permission = kwargs['permission']
      @group = Group.new(**kwargs['group'])
    end
  end
end
