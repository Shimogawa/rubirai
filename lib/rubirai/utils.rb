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
  def camel_case(lower: false)
    s = split('_').collect(&:capitalize).join
    return s unless lower
    # noinspection RubyNilAnalysis
    s[0] = s[0].downcase
    s
  end
end
