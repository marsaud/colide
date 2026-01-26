local function new (self, o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

local Trait = {
  new = new,
  __add = function (t1, t2)
    t3 = {}
    for k, v in pairs(t1) do
      t3[k] = v
    end
    for k, v in pairs(t2) do
      t3[k] = v
    end
    return t3
  end
}

return function () return new, Trait end