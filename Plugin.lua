local PluginManager = {
  _initPluginManager = function(self)
    if self._pluginManagerInit then
      return
    end
    self._plugins = {}
    self._pluginManagerInit = true
  end,
  addPlugin = function(self, id, funcOrObj)
    self:_initPluginManager()
    if not self._plugins[id] then
      self._plugins[id] = {}
    end
    if type(funcOrObj) == "table" and not funcOrObj[id] then
      error("invalid plugin")
    end
    table.insert(self._plugins[id], funcOrObj)
  end,
  runPlugins = function(self, id, ...)
    self:_initPluginManager()
    for _, funcOrObj in ipairs(self._plugins[id] or {}) do
      if type(funcOrObj) == "table" and funcOrObj[id] then
        funcOrObj[id](funcOrObj, ...)
      elseif type(funcOrObj) == "function" then
        funcOrObj(...)
      end
    end
  end,
}

return function()
  return PluginManager
end
