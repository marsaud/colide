local C = require("Const")
local DEFAULT_CONTROL_CHANNEL = C.DEFAULT_CONTROL_CHANNEL

local IAState = {
  update = function(self, ctrl, dt, channel)
    local result = false
    if (self.channel or DEFAULT_CONTROL_CHANNEL) ~= (channel or DEFAULT_CONTROL_CHANNEL) then
      return result
    end
    if self.runPrePlugins then
      result = self:runPrePlugins("update", self, ctrl, dt)
    end
    if self._update then
      result = self:_update(ctrl, dt) or result
    end
    if self.runPostPlugins then
      result = self:runPostPlugins("update", self, ctrl, dt)
    end
    return result
  end,

  flush = function(self)
    local result = false
    if self.runPrePlugins then
      result = self:runPrePlugins("flush", self)
    end
    if self._flush then
      result = self:_flush() or result
    end
    if self.runPostPlugins then
      result = self:runPostPlugins("flush", self) or result
    end
    return result
  end,
}

return {
  IAState = IAState,
}
