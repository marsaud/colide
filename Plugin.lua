local C = require("Const")
local PLUGIN = C.PLUGIN

local PluginManager = {
  _constructors = {
    PluginManager = function(self)
      if not self._plugins then
        self._plugins = {}
      end
    end,
  },

  addPlugin = function(self, id, funcOrObj)
    if not self._plugins[id] then
      self._plugins[id] = {}
    end
    if type(funcOrObj) == "table" and not funcOrObj[id] then
      error("invalid plugin")
    end
    table.insert(self._plugins[id], funcOrObj)
  end,

  runPlugins = function(self, id, ...)
    local result = false
    local sum = 0
    for _, funcOrObj in ipairs(self._plugins[id] or {}) do
      local response
      if type(funcOrObj) == "table" and funcOrObj[id] then
        response = funcOrObj[id](funcOrObj, ...)
      elseif type(funcOrObj) == "function" then
        response = funcOrObj(...)
      end
      if type(response) == "boolean" then
        result = response or result
      end
      if type(response) == "number" then
        sum = sum + response
      end
    end
    return result, sum
  end,
}

return {
  PluginManager = PluginManager,
}
