local IAState = {
  update = function(self, id, ctrl, dt)
    if self.runPlugins then
      self:runPlugins("update", self, id, ctrl, dt)
    end
    if self._update then
      return self:_update(id, ctrl, dt)
    end
  end,

  flush = function(self, id)
    if self.runPlugins then
      self:runPlugins("flush", self, id)
    end
    if self._flush then
      return self:_flush(id)
    end
  end,
}

return {
  IAState = IAState,
}
