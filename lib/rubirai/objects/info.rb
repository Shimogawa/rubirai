# frozen_string_literal: true

require 'rubirai/utils'

module Rubirai
  class Info
    # @!method initialize(hash)
    #   @param hash [Hash{String => Object}]
    def self.set_fields(*fields, **default_values)
      attr_reader(*fields)

      class_eval do
        define_method(:initialize) do |hash|
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
  end

  class GroupConfig < Info
    set_modifiable_fields :name, :announcement, :confess_talk, :allow_member_invite, :auto_approve, :anonymous_chat
  end

  class MemberInfo < Info
    set_fields :name, :nick, :special_title
    attr_writer :name, :special_title
  end

  class GroupFileSimple < Info
    set_fields :name, :id, :path, :is_file, is_file: true
  end

  class GroupFile < GroupFileSimple
    set_fields :length, :download_times, :uploader_id, :upload_time, :last_modify_time, :download_url, :sha1, :md5
  end
end
