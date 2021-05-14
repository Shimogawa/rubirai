# frozen_string_literal: true

module Rubirai
  RETURN_CODE = {
    0 => 'OK',
    1 => 'Wrong auth key',
    2 => 'No such bot',
    3 => 'Session disappeared',
    4 => 'Session not verified',
    5 => 'No such receiver',
    6 => 'No such file',
    10 => 'No permission',
    20 => 'Bot muted',
    30 => 'Message too long',
    400 => 'Bad request'
  }.freeze
end
