# frozen_string_literal: true

module Rubirai
  # Http response error
  class HttpResponseError < RuntimeError
    def initialize(code)
      super "Http Error: #{code}"
    end
  end

  class MiraiError < RuntimeError
    def initialize(code)
      super "Mirai error: #{code} - #{Rubirai::RETURN_CODE[code]}"
    end
  end

  class RubiraiError < RuntimeError
  end
end
