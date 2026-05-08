local IAState = {
  update = function(self, id, ctrl, dt)
    if self.runPlugins then
      self:runPlugins("update", self, id, ctrl, dt)
    end
    if self._update then
      return self:_update(id, ctrl, dt)
    end
  end,
}

return function()
  return IAState
end
