# frozen_string_literal: true

require 'rubirai/objects/group'

module Rubirai
  class Event
    private_class_method :descendants, :metaclass

    def self.gen_descendants
      descs = ObjectSpace.each_object(Class).select do |klass|
        klass < self
      end

      metaclass.instance_eval do
        define_method(:descendants) do
          descs
        end
      end
    end

    def self.all_types
      descendants.map(&:type)
    end

    def valid_type?(type)
      all_types.include? type
    end

    def self.set_event(type, *attr_keys)
      attr_reader(*attr_keys)

      metaclass.instance_eval do
        return if type.nil?
        define_method(:type) do
          type
        end
      end

      class_eval do
        define_method(:initialize) do |hash|
          # noinspection RubySuperCallWithoutSuperclassInspection
          super hash
          hash = hash.stringify_keys
          attr_keys.each do |k|
            k2 = k.to_s.snake_to_camel(lower: true)
            val = hash[k2]
            val = case k2
                  when 'group'
                    Group.new(**val)
                  when 'operator', 'member'
                    GroupUser.new(**val)
                  when 'sender'
                    if val.key? 'group'
                      GroupUser.new(**val)
                    else
                      User.new(**val)
                    end
                  when 'messageChain'
                    MessageChain.new val
                  else
                    val
                  end
            instance_variable_set("@#{k}", val)
          end
        end
      end
    end

    def self.metaclass
      class << self
        self
      end
    end
  end
end

require_relative 'bot_events'

Rubirai::Event.gen_descendants
