local Class = require("OOP").Class

local function printT(t, p)
  if type(t) == "table" then
    print(t)
    for k, v in pairs(t) do
      print((p or "") .. "\t", k, v)
      -- printT(v, "\t")
    end
  end
end

local run = function()
  local A = Class({
    __constructors = {
      A = function(self)
        self._a = 1
      end,
    },
    getA = function(self)
      return self._a
    end,
  })
  local ainst = A:new()
  printT(ainst)
  printT(ainst.__constructors.keys)
  printT(ainst.__constructors.values)
  print("---")

  local B = A:extend({
    __constructors = {
      B = function(self)
        self._b = 2
      end,
    },
    getB = function(self)
      return self._b
    end,
  })
  local binst = B:new()
  printT(binst)
  printT(binst.__constructors.keys)
  printT(binst.__constructors.values)
  print("---")

  local C = B:extend({
    __constructors = {
      C = function(self)
        self._c = 3
      end,
    },
    getC = function(self)
      return self._c
    end,
  })
  local cinst = C:new()
  printT(cinst)
  printT(cinst.__constructors.keys)
  printT(cinst.__constructors.values)
  print("---")

  ainst._a = 11
  binst._a = 22
  binst._b = 222
  cinst._a = 33
  cinst._b = 333
  cinst._c = 3333
  printT(ainst)
  print("---")
  printT(binst)
  print("---")
  printT(cinst)
  print("---")
  print(ainst:getA(), binst:getA(), binst:getB(), cinst:getA(), cinst:getB(), cinst:getC())
  local c2 = C:new()
  c2._a = 5
  c2._b = 55
  c2._c = 555
  print(c2:getA(), c2:getB(), c2:getC(), cinst:getA(), cinst:getB(), cinst:getC())
end

return run, "OOP.lua"
