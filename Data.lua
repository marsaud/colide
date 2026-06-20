local Class = require("OOP")()

local DataManager = Class({
  _constructors = {
    DataManager = function(self)
      if not self._objects then
        self._objects = {}
      end
      self._ID = 0
    end,
  },

  _id = function(self)
    self._ID = self._ID + 1
    return self._ID
  end,

  subscribe = function(self, o, key)
    if not o.dataPush then
      return false
    end
    if not o.__DATA_INDEX then
      o.__DATA_INDEX = {}
    end
    o.__DATA_INDEX[key] = self:_id()
    if not self._objects[key] then
      self._objects[key] = {}
    end
    self._objects[key][o.__DATA_INDEX[key]] = o
    o.DataManager = self
    return true
  end,

  push = function(self, key, value)
    local objects = self._objects[key]
    if objects then
      for _, o in pairs(objects) do
        o:dataPush(key, value)
      end
    end
  end,
})

return function()
  return DataManager
end
