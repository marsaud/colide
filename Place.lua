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
      print("IAPlace:constructor", self.id, self.x, self.y)
      self._c = Coord:new({ x = self.x, y = self.y }) -- internal coord
    end,
  },
}

return function()
  return IAPlace
end
