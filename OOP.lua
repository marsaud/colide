local OrderedTable = require("OrderedTable")()

local function _aggregateTables(...)
  local arg = { ... }
  local agg = {
    _constructors = OrderedTable:new(),
  }
  for _, t in ipairs(arg) do
    for key, val in pairs(t) do
      if key == "_constructors" then
        if val.iterate then
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

local function new(self, ...)
  local o = _aggregateTables(...)
  local _constructors = self._constructors or OrderedTable:new()
  for key, val in o._constructors:iterate() do
    _constructors:set(key, val)
  end
  self._constructors = _constructors
  o._constructors = nil
  setmetatable(o, self)
  self.__index = self
  if self._constructors then
    for _, c in self._constructors:iterate() do
      c(o)
    end
  end
  return o
end

local function Class(...)
  return _aggregateTables({ new = new }, ...)
end

return function()
  return Class
end
