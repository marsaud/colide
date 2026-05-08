local Class = require("OOP")()
local pullControl = require("Control")()
local _, _, EVENT, _ = require("Const")()
local debug = require("Debug")()

local eventCount = 0

local getEventId = function()
  eventCount = eventCount + 1
  return "e" .. eventCount
end

local EventManager = Class({
  tick = function(self, dt)
    local ctrl = pullControl()
    local objs = self._objects or {}
    for _, u in ipairs(objs) do
      if u.update then
        u:update(ctrl, dt)
      end
    end
    return self:fire(EVENT.CONTROL, nil, ctrl, dt)
  end,

  draw = function(self)
    return self:fire(EVENT.DRAW)
  end,

  getObjects = function(self)
    return self._objects
  end,

  addObjects = function(self, ...)
    if not self._objects then
      self._objects = {}
    end
    local arg = { ... }
    for _, o in ipairs(arg) do
      if o.group then
        error("EventManager: do not add objects belonging to groups")
      end
      table.insert(self._objects, o)
      if o._group then
        self:_addObjects(table.unpack(o._group))
      end
      o.eventManager = self
    end
  end,

  _addObjects = function(self, ...)
    if not self._objects then
      self._objects = {}
    end
    local arg = { ... }
    for _, o in ipairs(arg) do
      table.insert(self._objects, o)
      o.eventManager = self
    end
  end,

  removeObjects = function(self, ...)
    local args = { ... }
    local objs = self._objects or {}
    for _, v in ipairs(args) do
      if not v.group then
        for i, o in ipairs(objs) do
          if v == o then
            if o._group then
              self:_removeObjects(table.unpack(o._group))
            end
            table.remove(objs, i)
            o.eventManager = nil
          end
        end
      end
    end
  end,

  _removeObjects = function(self, ...)
    local args = { ... }
    local objs = self._objects or {}
    for _, v in ipairs(args) do
      for i, o in ipairs(objs) do
        if v == o then
          table.remove(objs, i)
          o.eventManager = nil
        end
      end
    end
  end,

  fire = function(self, e, id, o, ...)
    if id == nil then
      id = getEventId()
    end
    -- debug('IN', id, e, o, ...)
    local effect = false
    if e == EVENT.MOVE and o ~= nil and o._group then
      for _, go in ipairs(o._group) do
        effect = self:fire(e, id, go, ...) or effect
      end
    end
    local objs = self._objects or {}
    for _, c in ipairs(objs) do
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

  delete = function(_, o)
    o._EV_DELETE = true
  end,

  purge = function(self)
    -- TODO rewrite relying on private methods handling groups
    local objs = self._objects or {}
    for i, o in ipairs(objs) do
      if o._EV_DELETE then
        table.remove(objs, i)
        o._EV_DELETE = nil
        o.eventManager = nil
      end
    end
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
