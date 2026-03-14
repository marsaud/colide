local Class = require("OOP")()
local pullControl = require("Control")()
local _, _, EVENT, _ = require("Const")()
-- local debug = require("Debug")()

local EventManager = Class({
  tick = function (self, dt)
    local ctrl = pullControl()
    return self:fire(EVENT.CONTROL, ctrl, dt)
  end,

  draw = function (self)
    return self:fire(EVENT.DRAW)
  end,

  getObjects = function (self)
    return self._objects
  end,

  addObjects = function (self, ...)
    if not self._objects then
      self._objects = {}
    end
    local arg = {...}
    for _, o in ipairs(arg) do
      if o.group then
        error("EventManager: don not add objects belonging to groups")
      end
      table.insert(self._objects, o)
      if o._group then
        self:_addObjects(table.unpack(o._group))
      end
      o.eventManager = self
    end
  end,

  _addObjects = function (self, ...)
    if not self._objects then
      self._objects = {}
    end
    local arg = {...}
    for _, o in ipairs(arg) do
      table.insert(self._objects, o)
      o.eventManager = self
    end
  end,

  removeObjects = function (self, ...)
    local args = {...}
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

  _removeObjects = function (self, ...)
    local args = {...}
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

  fire = function (self, e, ...)
    local objs = self._objects or {}
    local effect = false
    for _, l in ipairs(objs) do
      if l.fire then
        effect = l:fire(e, ...) or effect
      end
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
    local objs = self._objects or {}
    for i, o in ipairs(objs) do
      if o._EV_DELETE then
        table.remove(objs, i)
        o._EV_DELETE = nil
        o.eventManager = nil
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