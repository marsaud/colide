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
  fire = function (self, e, ...)
    local arg = {...}
    local o = table.remove(arg)
    while o do
      if self == o then return false end
      o = table.remove(arg)
    end
    o = ({...})[1]
    if e == EVENT.MOVE then
      -- print(obj.id, '_resolve', self.id)
      o:rresolve(self, ...)
    end
  end
})

return function () return EVENT, EventManager, IEventCatcher end