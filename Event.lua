local Class = require("OOP")()
local pullControl = require("Control")()
local _COLOR, _CONTROL, EVENT, _MOVE, _PLUGIN, _STYLE = require("Const")()
-- local debug = require("Debug")()

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
  _constructors = {
    EventManager = function(self)
      if not self._objects then
        self._objects = {
          [EVENT.COMMIT] = {},
          [EVENT.CONTROL] = {},
          [EVENT.DRAW] = {},
          [EVENT.HIT] = {},
          [EVENT.MOVE] = {},
          [EVENT.UPDATE] = {},
        }
      end
      self._ID = 0
    end,
  },

  _id = function(self)
    self._ID = self._ID + 1
    return self._ID
  end,

  tick = function(self, dt)
    local ctrl = pullControl()
    for _, u in pairs(self._objects[EVENT.UPDATE]) do
      u:update(ctrl, dt)
    end
    for _, c in pairs(self._objects[EVENT.CONTROL]) do
      c:control(ctrl, dt)
    end
  end,

  draw = function(self)
    for _, d in pairs(self._objects[EVENT.DRAW]) do
      d:draw()
    end
  end,

  getObjects = function(self)
    return self._objects
  end,

  _insert = function(self, o)
    o.__EV_INDEX = {}
    local inserted = false
    for _, e in pairs(EVENT) do
      if o[e] then
        o.__EV_INDEX[e] = self:_id()
        self._objects[e][o.__EV_INDEX[e]] = o
        inserted = true
      end
    end
    if inserted then
      o.eventManager = self
      return true
    else
      o.__EV_INDEX = nil
      return false
    end
  end,

  _remove = function(self, o)
    for e, pos in pairs(o.__EV_INDEX) do
      self._objects[e][pos] = nil
    end
    o.eventManager = nil
    o.__EV_INDEX = nil
  end,

  addObjects = function(self, ...)
    local arg = { ... }
    for _, o in ipairs(arg) do
      if o.group then
        error("EventManager: do not add objects belonging to groups")
      end
      self:_insert(o)
      if o._group then
        self:_addObjects(table.unpack(o._group))
      end
    end
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
      if not v.group then
        if v._group then
          self:_removeObjects(table.unpack(v._group))
        end
        self:_remove(v)
      end
    end
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
    if e == EVENT.MOVE and o ~= nil and o._group then
      for _, go in ipairs(o._group) do
        effect = self:fire(e, id, go, ...) or effect
      end
    end
    for _, c in pairs(self._objects[e]) do
      if c.catch then
        effect = c:catch(e, id, o, ...) or effect
      end
    end
    if e == EVENT.MOVE and not o.group and #{ o, ... } <= 1 then
      self:fire(EVENT.COMMIT, id)
    end
    -- debug('OUT', id, e, o, ...)
    return effect
  end,

  delete = function(self, o)
    if not self._deleted then
      self._deleted = {}
    end
    table.insert(self._deleted, o)
  end,

  purge = function(self)
    if self._deleted then
      for _, o in ipairs(self._deleted) do
        if o.group then
          o.group:remove(o)
        end
        self:removeObjects(o)
      end
    end
    self._deleted = nil
  end,
})

local IEventCatcher = {
  catch = function(self, e, id, ...)
    if not self[e] then
      return false
    end
    -- debug('CATCH', id, self, e, ...)
    return self[e](self, id, ...)
  end,
}

return function()
  return EventManager, IEventCatcher
end
