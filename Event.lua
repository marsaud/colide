local Class = require("POO")()
-- local debug = require("Debug")()

local EVENT = {
  MOVE = 'eventMove',
  COMMIT = 'eventCommit',
  HIT = 'eventHit'
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
  fire = function (self, e, emitter, ...)
    local ls = self._listeners[e] or {}
    local effect = false
    for _, l in ipairs(ls) do
      effect = l:fire(e, emitter, ...) or effect
    end
    if e == EVENT.MOVE and #{...} == 0 then
      self:fire(EVENT.COMMIT)
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
  end
})

local IEventCatcher = {
  fire = function (self, e, o, ...)
    if e == EVENT.MOVE then
      if self == o then return false end
      if not o.IACollide then return false end
      local arg = {...}
      for _, _o in ipairs(arg) do
        if self == _o then
          return false
        end
      end
      local r = o:resolve(self,...)
      return r
    elseif e == EVENT.COMMIT then
      if not self.IAMove then return false end
      self:commit()
    elseif e == EVENT.HIT then
      local arg = {...}
      if self == o and self.hit then
        return self:hit(arg[1], arg[2])
      end
    else
      return false
    end
  end
}

return function () return EVENT, EventManager, IEventCatcher end