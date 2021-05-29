# frozen_string_literal: true

require 'rubirai/utils'

module Rubirai
  # The abstract class for group information
  # @abstract
  class GroupInfo
    def self.set_fields(*fields, **default_values)
      attr_reader(*fields)

      class_eval do
        define_method(:initialize) do |hash, bot = nil|
          # noinspection RubySuperCallWithoutSuperclassInspection
          super hash, bot
          fields.each do |field|
            value = hash[field.to_s.snake_to_camel(lower: true)] || default_values[field]
            instance_variable_set("@#{field}", value)
          end
        end

        define_method(:to_h) do
          fields.to_h do |field|
            [field.to_s.snake_to_camel(lower: true), instance_variable_get(field)]
          end.compact
        end
      end
    end

    def self.set_modifiable_fields(*fields)
      set_fields(*fields)
      attr_writer(*fields)
    end

    attr_reader :raw, :bot

    def initialize(hash, bot = nil)
      @raw = hash
      @bot = bot
    end
  end

  # Group config
  class GroupConfig < GroupInfo
    # @!method initialize(hash, bot = nil)
    #   @param hash [Hash{String => Object}]
    #   @param bot [Rubirai::Bot, nil]
    # @!method to_h
    #   @return [Hash{String => Object}]
    # @!attribute [rw] name
    #   @return [String]
    # @!attribute [rw] announcement
    #   @return [String]
    # @!attribute [rw] confess_talk
    #   @return [Boolean] is confess talk enabled
    # @!attribute [rw] allow_member_invite
    #   @return [Boolean]
    # @!attribute [rw] auto_approve
    #   @return [Boolean]
    # @!attribute [rw] anonymous_chat
    #   @return [Boolean] is anonymous chat enabled
    set_modifiable_fields :name, :announcement, :confess_talk, :allow_member_invite, :auto_approve, :anonymous_chat
  end

  # Member info
  class MemberInfo < GroupInfo
    # @!method initialize(hash, bot = nil)
    #   @param hash [Hash{String => Object}]
    #   @param bot [Rubirai::Bot, nil]
    # @!method to_h
    #   @return [Hash{String => Object}]
    # @!attribute [rw] name
    #   @return [String]
    # @!attribute [r] nick
    #   @return [String]
    # @!attribute [rw] special_title
    #   @return [String]
    set_fields :name, :nick, :special_title
    attr_writer :name, :special_title
  end

  # Group file with less information
  class GroupFileSimple < GroupInfo
    # @!method initialize(hash, bot = nil)
    #   @param hash [Hash{String => Object}]
    #   @param bot [Rubirai::Bot, nil]
    # @!method to_h
    #   @return [Hash{String => Object}]
    # @!attribute [r] name
    #   @return [String]
    # @!attribute [r] id
    #   @return [Integer]
    # @!attribute [r] is_file
    #   @return [Boolean]
    set_fields :name, :id, :path, :is_file, is_file: true
  end

  # Group file with detailed information
  class GroupFile < GroupFileSimple
    # @!method initialize(hash, bot = nil)
    #   @param hash [Hash{String => Object}]
    #   @param bot [Rubirai::Bot, nil]
    # @!method to_h
    #   @return [Hash{String => Object}]
    # @!attribute [r] length
    #   @return [Integer]
    # @!attribute [r] download_times
    #   @return [Integer]
    # @!attribute [r] uploader_id
    #   @return [Integer]
    # @!attribute [r] upload_time
    #   @return [Integer]
    # @!attribute [r] last_modify_time
    #   @return [Integer]
    # @!attribute [r] download_url
    #   @return [String]
    # @!attribute [r] sha1
    #   @return [String]
    # @!attribute [r] md5
    #   @return [String]
    set_fields :length,
               :download_times,
               :uploader_id,
               :upload_time,
               :last_modify_time,
               :download_url,
               :sha1,
               :md5
  end
end
