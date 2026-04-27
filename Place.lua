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

  d = function(self, value)
    local origin = self._origin and self._origin._d
    local d
    if origin then
      if value then
        self._d = value - origin
      end
      d = self._d + origin
    else
      if value then
        self._d = value:copy()
      end
      d = self._d:copy()
    end
    return d:round()
  end,

  c = function(self, value)
    local origin = self._origin and self._origin._c
    local c
    if origin then
      if value then
        self._c = value - origin
      end
      c = self._c + origin
    else
      if value then
        self._c = value:copy()
      end
      c = self._c
    end
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
