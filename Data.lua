local OOP = require("OOP")
local Class = OOP.Class
local State = require("State")
local IAState = State.IAState

local DataManager = Class({
  _constructors = {
    DataManager = function(self)
      if not self._listeners then
        self._listeners = {}
      end
      if not self._broadCasters then
        self._broadCasters = {}
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
    if not o.__DATA_LIST_INDEX then
      o.__DATA_LIST_INDEX = {}
    end
    o.__DATA_LIST_INDEX[key] = self:_id()
    if not self._listeners[key] then
      self._listeners[key] = {}
    end
    self._listeners[key][o.__DATA_LIST_INDEX[key]] = o
    o.DataManager = self
    return true
  end,

  unsubscribe = function(self, o, key)
    for _key, id in pairs(o.__DATA_LIST_INDEX) do
      if not key or key == _key then
        self._listeners[_key][id] = nil
        o.__DATA_LIST_INDEX[_key] = nil
      end
    end
    if #o.__DATA_LIST_INDEX == 0 then
      o.__DATA_LIST_INDEX = nil
      o.dataManager = nil
    end
  end,

  register = function(self, o, key)
    if not o.getData then
      return false
    end
    if not o.__DATA_BROAD_INDEX then
      o.__DATA_BROAD_INDEX = {}
    end
    o.__DATA_BROAD_INDEX[key] = self:_id()
    if not self._broadCasters[key] then
      self._broadCasters[key] = {}
    end
    self._broadCasters[key][o.__DATA_BROAD_INDEX[key]] = o
    o.dataManager = self
    return true
  end,

  unregister = function(self, o, key)
    for _key, id in pairs(o.__DATA_BROAD_INDEX) do
      if not key or key == _key then
        self._broadCasters[_key][id] = nil
        o.__DATA_BROAD_INDEX[_key] = nil
      end
    end
    if #o.__DATA_BROAD_INDEX == 0 then
      o.__DATA_BROAD_INDEX = nil
      o.dataManager = nil
    end
  end,

  broadCast = function(self)
    for key, broadCasters in pairs(self._broadCasters) do
      for _, br in pairs(broadCasters) do
        if br.getData then
          local value = br:getData()
          self:push(key, value)
        end
      end
    end
  end,

  push = function(self, key, value)
    local objects = self._listeners[key]
    if objects then
      for _, o in pairs(objects) do
        o:dataPush(key, value)
      end
    end
  end,

  _flush = function(self, _id)
    self:broadCast()
  end,
}, IAState)

return {
  DataManager = DataManager,
}
