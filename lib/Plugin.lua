local L = require("lib")
local C = require("Const")
local PLUGIN = C.PLUGIN

local PluginManager = {
  _constructors = {
    PluginManager = function(self)
      if not L.x(self[PLUGIN.PRE]) then
        self[PLUGIN.PRE] = {}
      end
      if not L.x(self[PLUGIN.POST]) then
        self[PLUGIN.POST] = {}
      end
    end,
  },

  addPlugin = function(self, id, funcOrObj)
    return self:addPrePlugin(id, funcOrObj)
  end,

  addPrePlugin = function(self, id, funcOrObj)
    return self:_addPlugin(PLUGIN.PRE, id, funcOrObj)
  end,

  addPostPlugin = function(self, id, funcOrObj)
    return self:_addPlugin(PLUGIN.POST, id, funcOrObj)
  end,

  _addPlugin = function(self, mapName, id, funcOrObj)
    if type(funcOrObj) == "table" and not L.x(funcOrObj[id]) then
      error("invalid plugin")
    end
    if type(funcOrObj) ~= "table" and type(funcOrObj) ~= "function" then
      error("invalid plugin")
    end
    if not L.x(self[mapName][id]) then
      self[mapName][id] = {}
    end
    table.insert(self[mapName][id], funcOrObj)
  end,

  runPlugins = function(self, id, ...)
    return self:runPrePlugins(id, ...)
  end,

  runPrePlugins = function(self, id, ...)
    return self:_runPlugins(PLUGIN.PRE, id, ...)
  end,

  runPostPlugins = function(self, id, ...)
    return self:_runPlugins(PLUGIN.POST, id, ...)
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
