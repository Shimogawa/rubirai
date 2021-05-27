# frozen_string_literal: true

# @private
class Hash
  def stringify_keys!
    transform_keys!(&:to_s)
  end

  def symbolize_keys!
    transform_keys!(&:to_sym)
  end

  def stringify_keys
    transform_keys(&:to_s)
  end

  def symbolize_keys
    transform_keys(&:to_sym)
  end
end

# @private
class String
  def snake_to_camel(lower: false)
    s = split('_').collect(&:capitalize).join
    return s unless lower
    # noinspection RubyNilAnalysis
    s[0] = s[0].downcase
    s
  end
end

# @private
class Object
  def must_be!(types, exc_type = nil, *args)
    ok = case types
         when Array
           types.any? { |type| is_a? type }
         else
           is_a? types
         end
    self.class.raise_or_default exc_type, "assert failed: `#{self}' must be of type #{types}", *args unless ok
  end

  def must_be_one_of!(things, exc_type = nil, *args)
    ok = case things
         when Array
           things.include? self
         else
           self == things
         end
    self.class.raise_or_default exc_type, "assert failed: `#{self}' must be one of: #{things}", *args unless ok
  end

  def self.raise_or_default(exc_type, msg, *args)
    if exc_type.nil?
      raise(msg)
    else
      raise(exc_type, *args)
    end
  end
end
