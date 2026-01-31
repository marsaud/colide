local function new (self, o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  if o._new then
    o:_new()
  end
  return o
end

local Trait
Trait = {
  new = new,
  __concat = function (t1, t2)
    local t3 = {}
    for k, v in pairs(t1) do
      t3[k] = v
    end
    for k, v in pairs(t2) do
      t3[k] = v
    end
    return Trait:new(t3)
  end
}

return function () return new, Trait end