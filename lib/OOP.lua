local O = require("OrderedTable")
local OrderedTable = O.OrderedTable

local function _aggregatePrototypes(...)
  local arg = { ... }
  local agg = {
    _constructors = OrderedTable:new(),
  }
  for _, t in ipairs(arg) do
    for key, val in pairs(t) do
      if key == "_constructors" then
        if val and type(val.iterate) == "function" then
          for name, constructor in val:iterate() do
            agg._constructors:set(name, constructor)
          end
        else
          for name, constructor in pairs(val) do
            agg._constructors:set(name, constructor)
          end
        end
      else
        agg[key] = val
      end
    end
  end
  return agg
end

local function extend(self, ...)
  local o = _aggregatePrototypes(self, ...)
  self.__index = self
  setmetatable(o, self)
  return o
end

local function new(self, ...)
  local o = self:extend(...)
  if o._constructors and type(o._constructors.iterate) == "function" then
    for _, c in self._constructors:iterate() do
      c(o)
    end
  end
  return o
end

local function Class(...)
  return _aggregatePrototypes({ new = new, extend = extend }, ...)
end

return {
  Class = Class,
}
