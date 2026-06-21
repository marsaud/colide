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
      if not self._broadcasters then
        self._broadcasters = {}
      end
      self._ID = 0
    end,
  },

  _id = function(self)
    self._ID = self._ID + 1
    return self._ID
  end,

  subscribe = function(self, o)
    if not o.pushData then
      return false
    end
    if not o.__DATA_LIST_INDEX then
      o.__DATA_LIST_INDEX = {}
    end
    local key = o:getKey()
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

  register = function(self, o, ...)
    if not o.getData then
      return false
    end
    if not o.__DATA_BROAD_INDEX then
      o.__DATA_BROAD_INDEX = {}
    end
    local keys = { ... }
    local key = o:getKey()
    if key then
      table.insert(keys, key)
    end
    if #keys == 0 then
      return false
    end
    for _, k in pairs(keys) do
      o.__DATA_BROAD_INDEX[key] = self:_id()
      if not self._broadcasters[key] then
        self._broadcasters[key] = {}
      end
      self._broadcasters[key][o.__DATA_BROAD_INDEX[key]] = o
    end
    o.dataManager = self
    return true
  end,

  unregister = function(self, o, key)
    for _key, id in pairs(o.__DATA_BROAD_INDEX) do
      if not key or key == _key then
        self._broadcasters[_key][id] = nil
        o.__DATA_BROAD_INDEX[_key] = nil
      end
    end
    if #o.__DATA_BROAD_INDEX == 0 then
      o.__DATA_BROAD_INDEX = nil
      o.dataManager = nil
    end
  end,

  broadcast = function(self)
    for key, broadcasters in pairs(self._broadcasters) do
      for _, br in pairs(broadcasters) do
        if br.getData then
          local value = br:getData()
          self:push(value, key)
        end
      end
    end
  end,

  push = function(self, value, key)
    local objects = self._listeners[key]
    if objects then
      for _, o in pairs(objects) do
        o:pushData(value, key)
      end
    end
  end,

  _flush = function(self, _id)
    self:broadcast()
  end,
}, IAState)

local IADataBroadcaster = {
  getKey = function(self)
    return self:_getKey()
  end,

  getData = function(self)
    return self:_getData()
  end,
}

local IADataListener = {
  getKey = function(self)
    return self:_getKey()
  end,

  pushData = function(self, value, key)
    if not key or key == self:getKey() then
      self:_pushData(value)
    end
  end,
}

return {
  DataManager = DataManager,
  IADataBroadcaster = IADataBroadcaster,
  IADataListener = IADataListener,
}
