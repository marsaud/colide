local Class = require("POO")()
local pullControl = require("Control")()
local _, _, EVENT, _ = require("Const")()
-- local debug = require("Debug")()

local EventManager = Class({
  init = function (self, objects)
    self._listeners = {}
    self._objects = objects
    for _, e in pairs(EVENT) do
      self:addListeners(e, table.unpack(self._objects))
    end
  end,
  tick = function (self, dt)
    local ctrl = pullControl()
    return self:fire(EVENT.CONTROL, ctrl, dt)
  end,
  getObjects = function (self)
    return self._objects
  end,
  addObject = function (self, o)
    for _, e in pairs(EVENT) do
      self:addListeners(e, o)
    end
    table.insert(self._objects, o)
  end,
  addListeners = function (self, e, ...)
    if not self._listeners[e] then
      self._listeners[e] = {}
    end
    local arg = {...}
    for _, l in ipairs(arg) do
      table.insert(self._listeners[e], l)
      l.eventManager = self
    end
  end,
  fire = function (self, e, ...)
    local ls = self._listeners[e] or {}
    local effect = false
    for _, l in ipairs(ls) do
      effect = l:fire(e, ...) or effect
    end
    if e == EVENT.MOVE and #{...} <= 1 then
      self:fire(EVENT.COMMIT)
    end
    return effect
  end,
  delete = function (_, o)
    o._EV_DELETE = true
  end,
  purge = function (self)
    for _, list in pairs(self._listeners) do
      for i, v in ipairs(list) do
        if v._EV_DELETE then
          table.remove(list, i)
        end
      end
    end
    for i, _o in ipairs(self._objects) do
      if _o._EV_DELETE then
        table.remove(self._objects, i)
        _o.eventManager = nil
      end
    end
  end
})

local IEventCatcher = {
  fire = function (self, e, ...)
    if not self[e] then return false end
    return self[e](self, ...)
  end
}

return function () return EventManager, IEventCatcher end