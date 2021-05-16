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
        all_types = descs.map(&:type)
        define_method(:all_types) do
          all_types
        end
        type_map = Hash(descs.map do |d|
          [d.type, d]
        end)
        define_method(:type_map) do
          type_map
        end
      end
    end

    def self.type_to_klass(type)
      # noinspection RubyResolve
      type_map[type]
    end

    def self.valid_type?(type)
      # noinspection RubyResolve
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

    def self.parse(hash)
      hash = hash.stringify_keys
      type_to_klass(hash['type']).new hash
    end

    attr_reader :raw

    def initialize(hash)
      @raw = hash
    end
  end
end

require_relative 'bot_events'

Rubirai::Event.gen_descendants
