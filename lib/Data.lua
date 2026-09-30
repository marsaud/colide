local OOP = require("OOP")
local Class = OOP.Class
local State = require("State")
local IAState = State.IAState
local L = require("lib")

local DataManager = Class({
  _constructors = {
    DataManager = function(self)
      if not L.x(self._listeners) then
        self._listeners = {}
      end
      if not L.x(self._broadcasters) then
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
    if not L.f(o.pushData) then
      return false
    end
    if not L.x(o.__DATA_LIST_INDEX) then
      o.__DATA_LIST_INDEX = {}
    end
    local keys = o:getKeys()
    for _, key in pairs(keys) do
      o.__DATA_LIST_INDEX[key] = self:_id()
      if not L.x(self._listeners[key]) then
        self._listeners[key] = {}
      end
      if self._listeners[key][o.__DATA_LIST_INDEX[key]] then
        error("Data suscribe slot not free")
      end
      self._listeners[key][o.__DATA_LIST_INDEX[key]] = o
    end
    o.DataManager = self
    return true
  end,

  unsubscribe = function(self, o, key)
    for _key, id in pairs(o.__DATA_LIST_INDEX) do
      if not L.x(key) or key == _key then
        self._listeners[_key][id] = nil
        o.__DATA_LIST_INDEX[_key] = nil
      end
    end
    if #o.__DATA_LIST_INDEX == 0 then
      o.__DATA_LIST_INDEX = nil
      o.dataManager = nil
    end
  end,

  register = function(self, o)
    if not L.f(o.getData) then
      return false
    end
    if not L.x(o.__DATA_BROAD_INDEX) then
      o.__DATA_BROAD_INDEX = {}
    end
    local keys = o:getKeys()
    if #keys == 0 then
      return false
    end
    for _, key in pairs(keys) do
      o.__DATA_BROAD_INDEX[key] = self:_id()
      if not L.x(self._broadcasters[key]) then
        self._broadcasters[key] = {}
      end
      if self._broadcasters[key][o.__DATA_BROAD_INDEX[key]] then
        error("Data register slot not free")
      end
      self._broadcasters[key][o.__DATA_BROAD_INDEX[key]] = o
    end
    o.dataManager = self
    return true
  end,

  unregister = function(self, o, key)
    for _key, id in pairs(o.__DATA_BROAD_INDEX) do
      if L.x(key) or key == _key then
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
          local value = br:getData(key)
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
  getKeys = function(self)
    return self:_getKeys()
  end,

  getData = function(self, key)
    return self:_getData(key)
  end,
}

local IADataListener = {
  getKeys = function(self)
    if self._getKeys then
      return self:_getKeys()
    else
      return {}
    end
  end,

  pushData = function(self, value, key)
    if self._pushData then
      self:_pushData(value, key)
    end
  end,
}

local DataStore = Class({
  _constructors = {
    DataStore = function(self)
      self._init = false
      self._store = {}
      if L.x(self.initial) then
        self:initialize(self.initial)
        self.initial = nil
      end
    end,
  },

  initialize = function(self, values)
    if self._init then
      error("Datastore already initialized.")
    end
    self._keySet = {}
    for key, value in pairs(values) do
      self._keySet[key] = true
      self:_write(key, value)
    end
    self._init = true
  end,

  write = function(self, key, value)
    if not self._init then
      error("Datastore not initialized")
    end
    if not self._keySet[key] then
      error("Unknown datastore key")
    end
    return self:_write(key, value)
  end,

  _write = function(self, key, value)
    self._store[key] = value
    if not self._diff then
      self._diff = {}
    end
    table.insert(self._diff, key)
    return self
  end,

  read = function(self, key)
    return self._store[key]
  end,
}, IADataBroadcaster, IAState)

return {
  DataManager = DataManager,
  DataStore = DataStore,
  IADataBroadcaster = IADataBroadcaster,
  IADataListener = IADataListener,
}
