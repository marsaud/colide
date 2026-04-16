-- local debug = require("Debug")()

local Coord, _, _, _ = require("Couple")()

local IAPlace = {
  _constructors = {
    IAPlace = function(self)
      if not self.x then
        self.x = 0
      end
      if not self.y then
        self.y = 0
      end
      self._c = Coord:new({ x = self.x, y = self.y }) -- internal coord
      self._d = self._c:copy() -- internal destination
    end,
  },

  d = function(self)
    local origin = self._origin and self._origin._d or Coord:new({x = 0, y = 0})
    local d = self._d + origin
    return d:round()
  end,

  c = function(self)
    local origin = self._origin and self._origin._c or Coord:new({x = 0, y = 0})
    local c = self._c + origin
    return c:round()
  end,

  setOrigin = function(self, origin)
    self._origin = origin
  end,

  removeOrigin = function(self)
    self._origin = nil
  end
}

return function()
  return IAPlace
end
