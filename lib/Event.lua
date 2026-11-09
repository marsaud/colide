local L = require("lib")
local OOP = require("OOP")
local Class = OOP.Class
local C = require("Const")
local EVENT = C.EVENT
local CONTROL = C.CONTROL
local DEFAULT_CONTROL_CHANNEL = C.DEFAULT_CONTROL_CHANNEL
local NotSerializable = require("Serializable").NotSerializable
-- local debug = require("Debug").debug
local Coord = require("Couple").Coord

local eventId = 0
local eventCount = 0

local getEventId = function(id)
  if id == nil then
    eventId = eventId + 1
    eventCount = 0
  else
    eventCount = eventCount + 1
  end
  return "e" .. eventId .. "." .. eventCount
end

local EventManager = Class({
  __constructors = {
    EventManager = function(self)
      if not L.x(self.controller) then
        error("AController instance required")
      end
      if L.t(self.keyMap) then
        self.__keyMap = self.keyMap
      end
      self.keyMap = nil
      self.__controller = self.controller
      self.controller = nil
      self.__objects = {}
      self.__objectIndex = {}
      for _, e in pairs(EVENT) do
        self.__objects[e] = {}
      end
      self._ID = 0
      self.__diffs = {}
    end,
  },

  _id = function(self)
    self._ID = self._ID + 1
    return self._ID
  end,

  startDiff = function(self)
    self.__diff = true
    for _, map in pairs(self.__objects) do
      for _, o in pairs(map) do
        self:registerDiff(o)
      end
    end
    return self
  end,

  tick = function(self, dt, dry)
    self.__controller:fetch()
    local lastControl = {}
    local ctrl, channel = self.__controller:poll()
    if dry then
      return self
    end
    while ctrl ~= nil do
      for _, c in pairs(self.__objects[EVENT.CONTROL]) do
        c:control(ctrl, dt, channel)
      end
      lastControl[channel] = ctrl
      ctrl, channel = self.__controller:poll()
    end
    for _, u in pairs(self.__objects[EVENT.UPDATE]) do
      local ch = u.channel or DEFAULT_CONTROL_CHANNEL
      u:update(lastControl[ch] or CONTROL.NONE, dt, ch)
    end
    return self
  end,

  flush = function(self)
    local stateDiff
    if self.__diff then
      local stateDiffMem = {}
      for o, _ in pairs(self.__diffs) do
        table.insert(stateDiffMem, o:serialize(self.__keyMap))
        self.__diffs[o] = nil
      end
      stateDiff = table.concat(stateDiffMem, "%")
    end
    self:purge()
    for _, f in pairs(self.__objects[EVENT.FLUSH]) do
      f:flush()
    end
    return self, stateDiff
  end,

  draw = function(self)
    for _, d in pairs(self.__objects[EVENT.DRAW]) do
      d:draw()
    end
    return self
  end,

  getObjects = function(self)
    return self.__objects
  end,

  _insert = function(self, o)
    if L.x(o.__eventManager) then
      error("Object " .. o.id .. " already managed")
    end
    o.__EV_INDEX = {}
    local inserted = false
    for _, e in pairs(EVENT) do
      if o[e] then
        o.__EV_INDEX[e] = self:_id()
        self.__objects[e][o.__EV_INDEX[e]] = o
        inserted = true
      end
    end
    if inserted then
      o.__eventManager = self
      if L.x(o._uid_) then
        self.__objectIndex[o._uid_] = o
      end
      return true
    else
      o.__EV_INDEX = nil
      return false
    end
  end,

  _remove = function(self, o)
    for e, id in pairs(o.__EV_INDEX) do
      self.__objects[e][id] = nil
    end
    o.__eventManager = nil
    o.__EV_INDEX = nil
    self.__objectIndex[o._uid_] = nil
  end,

  addObjects = function(self, ...)
    local arg = { ... }
    for _, o in ipairs(arg) do
      if L.x(o.group) then
        error("EventManager: do not add objects belonging to groups")
      end
      self:_insert(o)
      if L.x(o._group) then
        self:_addObjects(table.unpack(o._group))
      end
    end
    return self
  end,

  _addObjects = function(self, ...)
    local arg = { ... }
    for _, o in ipairs(arg) do
      self:_insert(o)
    end
  end,

  removeObjects = function(self, ...)
    local args = { ... }
    for _, v in ipairs(args) do
      if not L.x(v.group) then
        if L.x(v._group) then
          self:_removeObjects(table.unpack(v._group))
        end
        self:_remove(v)
      end
    end
    return self
  end,

  _removeObjects = function(self, ...)
    local args = { ... }
    for _, v in ipairs(args) do
      self:_remove(v)
    end
  end,

  fire = function(self, e, id, o, ...)
    id = getEventId(id)
    -- debug('IN', id, e, o, ...)
    local effect = false
    if e == EVENT.MOVE and o and o._group then
      for _, go in ipairs(o._group) do
        effect = self:fire(e, id, go, ...) or effect
      end
    end
    for _, c in pairs(self.__objects[e]) do
      if c.catch then
        local _effect = c:catch(e, id, o, ...)
        effect = _effect or effect
        if e == EVENT.COMMIT and _effect and self.__diff then
          self:registerDiff(c)
        end
      end
    end
    if e == EVENT.MOVE and not o.group and #{ o, ... } <= 1 then
      self:fire(EVENT.COMMIT, id)
    end
    -- debug('OUT', id, e, o, ...)
    return effect
  end,

  updateObject = function(self, o)
    local _o = self.__objectIndex[o._uid_]
    if not L.x(_o) then
      return
    end
    _o.h = o.h
    _o.w = o.w
    _o._health = o.health
    _o._c = Coord:new({ x = o._c.x, y = o._c.y })
  end,

  delete = function(self, o)
    if not L.x(self.__deleted) then
      self.__deleted = {}
    end
    o._DELETED = true
    table.insert(self.__deleted, o)
  end,

  purge = function(self)
    if self.__deleted then
      for _, o in ipairs(self.__deleted) do
        if o.group then
          o.group:remove(o)
        end
        self:removeObjects(o)
      end
    end
    self.__deleted = nil
    return self
  end,

  registerDiff = function(self, o)
    if not L.x(o.serialize) then
      return
    end
    if not L.x(o.__eventManager) or o.__eventManager ~= self then
      error("EventManager: unexpected object for diff register")
    end
    self.__diffs[o] = true
  end,
}, NotSerializable)

local IEventCatcher = {
  catch = function(self, e, id, ...)
    if not self[e] then
      return false
    end
    -- debug('CATCH', id, self, e, ...)
    return self[e](self, id, ...)
  end,
}

return {
  EventManager = EventManager,
  IEventCatcher = IEventCatcher,
}
