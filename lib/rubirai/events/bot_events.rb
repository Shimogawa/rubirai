# frozen_string_literal: true

require 'rubirai/events/event'

module Rubirai
  class BotEvent < Event
    set_event nil, :qq
  end

  class BotOnlineEvent < BotEvent
    set_event :BotOnlineEvent
  end

  class BotActiveOfflineEvent < BotEvent
    set_event :BotOfflineEventActive
  end

  class BotForcedOfflineEvent < BotEvent
    set_event :BotOfflineEventForce
  end

  class BotDroppedEvent < BotEvent
    set_event :BotOfflineEventDropped
  end

  class BotReloginEvent < BotEvent
    set_event :BotReloginEvent
  end

  class BotGroupPermissionChangedEvent < BotEvent
    set_event :BotGroupPermissionChangedEvent, :origin, :new, :current, :group
  end
end
