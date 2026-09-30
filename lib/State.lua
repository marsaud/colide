local IAState = {
  update = function(self, id, ctrl, dt)
    local result = false
    if self.runPrePlugins then
      result = self:runPrePlugins("update", self, id, ctrl, dt)
    end
    if self._update then
      result = self:_update(id, ctrl, dt) or result
    end
    if self.runPostPlugins then
      result = self:runPostPlugins("update", self, id, ctrl, dt)
    end
    return result
  end,

  flush = function(self, id)
    local result = false
    if self.runPrePlugins then
      result = self:runPrePlugins("flush", self, id)
    end
    if self._flush then
      result = self:_flush(id) or result
    end
    if self.runPostPlugins then
      result = self:runPostPlugins("flush", self, id) or result
    end
    return result
  end,
}

return {
  IAState = IAState,
}
