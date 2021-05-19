# frozen_string_literal: true

require 'rubirai/events/event'

module Rubirai
  class MessageEvent < Event
    set_event nil, :message_chain, :sender
  end

  class FriendMessageEvent < MessageEvent
    set_event :FriendMessage
  end

  class GroupMessageEvent < MessageEvent
    set_event :GroupMessage
  end

  class RecallEvent < Event
    set_event nil, :author_id, :message_id, :time
  end

  class GroupRecallEvent < RecallEvent
    set_event :GroupRecallEvent, :group, :operator
  end

  class FriendRecallEvent < RecallEvent
    set_event :FriendRecallEvent, :operator
  end
end
