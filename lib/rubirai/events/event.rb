# frozen_string_literal: true

require 'rubirai/objects/group'
require 'rubirai/utils'

module Rubirai
  class Event
    def self.gen_descendants
      descs = ObjectSpace.each_object(Class).select do |klass|
        klass < self
      end

      metaclass.instance_eval do
        define_method(:descendants) do
          descs
        end
        leaf_descs = descs.filter { |d| d.respond_to? :type }
        all_types = leaf_descs.map(&:type)
        define_method(:all_types) do
          all_types
        end
        type_map = leaf_descs.to_h { |d| [d.type, d] }
        define_method(:type_map) do
          type_map
        end
      end

      private_class_method :descendants
    end

    def self.type_to_klass(type)
      # noinspection RubyResolve
      type_map[type]
    end

    def self.valid_type?(type)
      # noinspection RubyResolve
      all_types.include? type
    end

    # @!method initialize(hash, bot = nil)
    #   @param hash [Hash]
    #   @param bot [Rubirai::Bot]
    def self.set_event(type, *attr_keys)
      attr_reader(*attr_keys)

      metaclass.instance_eval do
        return if type.nil?
        define_method(:type) do
          type
        end
      end

      class_eval do
        define_method(:initialize) do |hash, bot = nil|
          # noinspection RubySuperCallWithoutSuperclassInspection
          super hash, bot
          hash = hash.stringify_keys
          attr_keys.each do |k|
            k2 = k.to_s.snake_to_camel(lower: true)
            val = hash[k2]
            val = case k2
                  when 'group'
                    Group.new val, bot
                  when 'operator', 'member'
                    GroupUser.new val, bot
                  when 'sender'
                    if val.key? 'group'
                      GroupUser.new val, bot
                    else
                      User.new val, bot
                    end
                  when 'messageChain'
                    MessageChain.new bot, val
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

    private_class_method :metaclass

    # @param hash [Hash]
    # @param bot [Rubirai::Bot, nil]
    def self.parse(hash, bot = nil)
      hash = hash.stringify_keys
      type_to_klass(hash['type']).new hash, bot
    end

    attr_reader :bot, :raw

    def initialize(hash, bot = nil)
      @raw = hash
      @bot = bot
    end
  end
end

require_relative 'bot_events'
require_relative 'message_events'

Rubirai::Event.gen_descendants
