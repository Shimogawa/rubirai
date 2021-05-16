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
      super "Mirai error: #{code} - #{Rubirai::RETURN_CODE[code]}"
    end
  end
end
