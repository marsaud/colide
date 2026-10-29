local C = require("Const")
local DEFAULT_CONTROL_CHANNEL = C.DEFAULT_CONTROL_CHANNEL

local IAState = {
  update = function(self, ctrl, dt, channel)
    local result = false
    if (self.channel or DEFAULT_CONTROL_CHANNEL) ~= (channel or DEFAULT_CONTROL_CHANNEL) then
      return result
    end
    if self.runPrePlugins then
      result = self:runPrePlugins("_update", ctrl, dt)
    end
    if self._update then
      result = self:_update(ctrl, dt) or result
    end
    if self.runPostPlugins then
      result = self:runPostPlugins("_update", ctrl, dt)
    end
    return result
  end,

  flush = function(self)
    local result = false
    if self.runPrePlugins then
      result = self:runPrePlugins("_flush")
    end
    if self._flush then
      result = self:_flush() or result
    end
    if self.runPostPlugins then
      result = self:runPostPlugins("_flush") or result
    end
    return result
  end,
}

local IStateMove = {
  _update = function(self, ctrl, dt)
    if self.move then
      return self:move(0, ctrl, dt)
    else
      return false
    end
  end,
}

return {
  IAState = IAState,
  IStateMove = IStateMove,
}
