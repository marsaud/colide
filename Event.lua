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
  _constructors = {
    EventManager = function(self)
      if not self._objects then
        self._objects = {}
      end
    end,
  },
  tick = function(self, dt)
    local ctrl = pullControl()
    for _, u in ipairs(self._objects) do
      if u.update then
        u:update(ctrl, dt)
      end
    end
    for _, c in ipairs(self._objects) do
      if c.control then
        c:control(ctrl, dt)
      end
    end
  end,

  draw = function(self)
    for _, d in ipairs(self._objects) do
      if d.draw then
        d:draw()
      end
    end
  end,

  getObjects = function(self)
    return self._objects
  end,

  addObjects = function(self, ...)
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
    local arg = { ... }
    for _, o in ipairs(arg) do
      table.insert(self._objects, o)
      o.eventManager = self
    end
  end,

  removeObjects = function(self, ...)
    local args = { ... }
    for _, v in ipairs(args) do
      if not v.group then
        for i, o in ipairs(self._objects) do
          if v == o then
            if o._group then
              self:_removeObjects(table.unpack(o._group))
            end
            table.remove(self._objects, i) -- TODO check if table modification may break the for loop
            o.eventManager = nil
          end
        end
      end
    end
  end,

  _removeObjects = function(self, ...)
    local args = { ... }
    for _, v in ipairs(args) do
      for i, o in ipairs(self._objects) do
        if v == o then
          table.remove(self._objects, i) -- TODO check if table modification may break the for loop
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
    for _, c in ipairs(self._objects) do
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
    for i, o in ipairs(self._objects) do
      if o._EV_DELETE then
        table.remove(self._objects, i)
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
