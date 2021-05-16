# frozen_string_literal: true

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

class String
  def snake_to_camel(lower: false)
    s = split('_').collect(&:capitalize).join
    return s unless lower
    # noinspection RubyNilAnalysis
    s[0] = s[0].downcase
    s
  end
end

class Object
  def must_be!(types, exc_type = nil, *args)
    ok = false
    case types
    when Array
      types.each do |type|
        ok ||= is_a? type
      end
    else
      ok = is_a? types
    end
    unless ok
      if exc_type.nil?
        raise("assert failed: `#{self}' must be of type #{types}")
      else
        raise(exc_type, *args)
      end
    end
  end
end
