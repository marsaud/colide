local function _aggregateTables(...)
  local arg = { ... }
  local agg = {
    _constructors = {},
  }
  for _, t in ipairs(arg) do
    for key, val in pairs(t) do
      if key == "_constructors" then
        for name, constructor in pairs(val) do
          agg._constructors[name] = constructor
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
  local _constructors = self._constructors or {}
  for key, val in pairs(o._constructors) do
    _constructors[key] = val
  end
  o._constructors = nil
  setmetatable(o, self)
  self.__index = self
  if self._constructors then
    for _, c in pairs(self._constructors) do
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
