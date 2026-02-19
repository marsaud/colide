local function _aggregateTables (...)
  local arg = {...}
  local agg = {}
  for _, t in ipairs(arg) do
    for k, v in pairs(t) do
      agg[k] = v
    end
  end
  return agg
end

local function new (self, ...)
  local o = _aggregateTables(...)
  setmetatable(o, self)
  self.__index = self
  if o._new then
    o:_new()
  end
  return o
end

local function Class (...)
  return _aggregateTables({new = new}, ...)
end

return function () return Class end