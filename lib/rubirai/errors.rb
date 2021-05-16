# frozen_string_literal: true

require 'rubirai/retcode'

module Rubirai
  class RubiraiError < RuntimeError
  end

  # Http response error
  class HttpResponseError < RubiraiError
    def initialize(code)
      super "Http Error: #{code}"
    end
  end

  class MiraiError < RubiraiError
    def initialize(code)
      raise(RubiraiError, 'invalid mirai error code') unless Rubirai::RETURN_CODE.key? code
      str = "Mirai error: #{code} - #{Rubirai::RETURN_CODE[code]}"
      super str
    end
  end
end
