local Class = require("POO")()
-- local debug = require("Debug")()

local EVENT = {
  CTRL ='eventCtrl',
  MOVE = 'resolve',
  COMMIT = 'commit',
  HIT = 'hit'
}

local EventManager = Class({
  init = function (self, objects)
    self._objects = objects
    for _, v in pairs(EVENT) do
      self:addListener(v, table.unpack(self._objects))
    end
  end,
  getObjects = function (self)
    return self._objects
  end,
  addListener = function (self, e, ...)
    if not self._listeners then
      self._listeners = {}
    end
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
    return effect
  end,
  purge = function (self, o)
    for _, list in pairs(self._listeners) do
      for i, v in ipairs(list) do
        if v == o then
          table.remove(list, i)
          break
        end
      end
      for i, _o in ipairs(self._objects) do
        if _o == o then
          table.remove(self._objects, i)
          break
        end
      end
    end
    o.eventManager = nil
  end
})

local IEventCatcher = {
  fire = function (self, e, ...)
    if not self[e] then return false end
    return self[e](self, ...)
  end
}

return function () return EVENT, EventManager, IEventCatcher end