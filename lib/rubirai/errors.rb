# frozen_string_literal: true

require 'rubirai/retcode'

module Rubirai
  # Represent all Rubirai errors
  class RubiraiError < RuntimeError
  end

  # Http response error
  class HttpResponseError < RubiraiError
    def initialize(code)
      super "Http Error: #{code}"
    end
  end

  # Mirai error
  class MiraiError < RubiraiError
    def initialize(code, msg = nil)
      raise(RubiraiError, 'invalid mirai error code') unless Rubirai::RETURN_CODE.key? code
      str = +"Mirai error: #{code} - #{Rubirai::RETURN_CODE[code]}"
      str << "\n#{msg}" if msg
      super str
    end
  end
end
