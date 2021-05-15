# frozen_string_literal: true

module Rubirai
  # Section of Bot about plugin information
  class Bot
    # Get Mirai API plugin information such as
    #   {
    #     version: '1.0.0'
    #   }
    # @return [Hash] plugin data
    def about
      v = call :get, '/about'
      v['data']
    end
  end
end
