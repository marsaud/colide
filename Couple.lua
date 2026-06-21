require("math-ext")

local Couple
local coupleMetatable

coupleMetatable = {
  __add = function(v1, v2)
    return Couple:new({
      x = v1.x + v2.x,
      y = v1.y + v2.y,
    })
  end,
  __sub = function(v1, v2)
    return Couple:new({
      x = v1.x - v2.x,
      y = v1.y - v2.y,
    })
  end,
  __mul = function(v, f)
    if type(f) ~= "number" then
      v, f = f, v
    end
    if getmetatable(v) ~= coupleMetatable then
      error("Type violation: Couple.__mul takes (Couple, number) or (number, Couple)")
    else
      return Couple:new({
        x = v.x * f,
        y = v.y * f,
      })
    end
  end,
  __div = function(v, d)
    if type(d) ~= "number" then
      v, d = d, v
    end
    if getmetatable(v) ~= Couple then
      error("Type violation: Couple.__div takes (Couple, number) or (number, Couple)")
    else
      return Couple:new({
        x = v.x / d,
        y = v.y / d,
      })
    end
  end,
  __eq = function(v1, v2)
    return v1.x == v2.x and v1.y == v2.y
  end,
  __unm = function(v)
    return Couple:new({ x = -v.x, y = -v.y })
  end,
  __index = {
    copy = function(self)
      return Couple:new({ x = self.x, y = self.y })
    end,
    round = function(self)
      return Couple:new({ x = math.round(self.x), y = math.round(self.y) })
    end,
  },
}

Couple = {
  new = function(_, c)
    if not c.x or not c.y then
      error("Couple objects require x and y properties")
    end
    setmetatable(c, coupleMetatable)
    return c
  end,
}

local Coord = Couple
local Point = Couple
local Size = Couple
local Vector = Couple

return {
  Coord = Coord,
  Point = Coord,
  Size = Size,
  Vector = Vector,
}
