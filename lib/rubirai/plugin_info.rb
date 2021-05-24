# frozen_string_literal: true

module Rubirai
  class Bot
    # Get Mirai API plugin information such as
    # ```ruby
    # {
    #   'version' => '1.0.0'
    # }
    # ```
    # @return [Hash{String => Object}] plugin data
    def about
      v = call :get, '/about'
      v['data']
    end
  end
end
