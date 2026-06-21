local C = require("Const")
local PLUGIN = C.PLUGIN

local PluginManager = {
  _constructors = {
    PluginManager = function(self)
      if not self._pre then
        self._pre = {}
      end
      if not self._post then
        self._post = {}
      end
    end,
  },

  addPlugin = function(self, id, funcOrObj)
    return self:addPrePlugin(id, funcOrObj)
  end,

  addPrePlugin = function(self, id, funcOrObj)
    return self:_addPlugin("_pre", id, funcOrObj)
  end,

  addPostPlugin = function(self, id, funcOrObj)
    return self:_addPlugin("_post", id, funcOrObj)
  end,

  _addPlugin = function(self, mapName, id, funcOrObj)
    if not self[mapName][id] then
      self[mapName][id] = {}
    end
    if type(funcOrObj) == "table" and not funcOrObj[id] then
      error("invalid plugin")
    end
    table.insert(self[mapName][id], funcOrObj)
  end,

  runPlugins = function(self, id, ...)
    return self:runPrePlugins(id, ...)
  end,

  runPrePlugins = function(self, id, ...)
    return self:_runPlugins("_pre", id, ...)
  end,

  runPostPlugins = function(self, id, ...)
    return self:_runPlugins("_post", id, ...)
  end,

  _runPlugins = function(self, mapName, id, ...)
    local result = false
    local sum = 0
    for _, funcOrObj in ipairs(self[mapName][id] or {}) do
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
