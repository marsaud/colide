local new, Trait = require("POO")()
-- local debug = require("Debug")()

local EVENT = {
  MOVE = 'eventMove',
  COMMIT = 'eventCommit'
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
  fire = function (self, e, emitter, ...)
    local ls = self._listeners[e] or {}
    local effect = false
    for _, l in ipairs(ls) do
      if (emitter ~= l) then
        effect = l:fire(e, emitter, ...) or effect
      end
    end
    if e == EVENT.MOVE and #{...} == 0 then
      self:fire(EVENT.COMMIT)
    end
    return effect
  end
}

local IEventCatcher = Trait:new({
  fire = function (self, e, o, ...)
    if e == EVENT.MOVE then
      if not o.IACollide then return false end
      local arg = {...}
      for _, _o in ipairs(arg) do
        if self == _o then
          return false
        end
      end
      local r = o:rresolve(self,...)
      return r
    elseif e == EVENT.COMMIT then
      if not self.IAMove then return false end
      self:commit()
    else
      return false
    end
  end
})

return function () return EVENT, EventManager, IEventCatcher end