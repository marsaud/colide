local new, Trait = require("POO")()

local EVENT = {
  MOVE = 'eventMove'
}

local EventManager = {
  new = new,
  _new = function (self)
    self._listeners = {}
  end,
  addListener = function (self, e, ...)
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
    for _, l in ipairs(ls) do
      l:fire(e, ...)
    end
  end
}

local IEventCatcher = Trait:new({
  fire = function (self, e, o, ...)
    local arg = {o, ...}
    for _, _o in ipairs(arg) do
      if self == _o then return false end
    end
    if e == EVENT.MOVE then
      -- print(obj.id, '_resolve', self.id)
      o:rresolve(self, ...)
    end
  end
})

return function () return EVENT, EventManager, IEventCatcher end