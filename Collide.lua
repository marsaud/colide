require("math-ext")
local _, Trait = require("POO")()
local Coord, _, _, Vector = require("Couple")()

local colStates = {
  BLOCK_1DX = 'blockX',
  BLOCK_1DY = 'blockY',
  PUSH_1DX = 'pushX',
  PUSH_1DY = 'pushY'
}

local IACollide = Trait:new({
  _initColState = function (self)
    self._colState = {}
  end,
  resolve = function (self, o)
    if self.d.x >= (o.d.x + o.w) then return true end -- right
    if (self.d.x + self.w) <= o.d.x then return true end -- left
    if self.d.y >= (o.d.y + o.h) then return true end -- under
    if (self.d.y + self.h) <= o.d.y then return true end
    if self._resolve then
      return self:_resolve(o)
    end
  end,

  _addColState = function (self, state)
    if (not self._colState) then
      self:_initColState()
    end
    table.insert(self._colState, state)
  end,

  blockX = function (self)
    self.vector = Vector:new({
      x = 0,
      y = self.vector.y
    })
    self._d = Coord:new({
      x = self._c.x,
      y = self._d.y
    })
    self.d = self._d:round()
    self:_addColState(colStates.BLOCK_1DX)
  end,

  blockY = function (self)
    self.vector = Vector:new({
      x = self.vector.x,
      y = 0
    })
    self._d = Coord:new({
      x = self._d.x,
      y = self._c.y
    })
    self.d = self._d:round()
    self:_addColState(colStates.BLOCK_1DY)
  end,

  pushX = function (self, o)
    self.vector = Vector:new({
      x = o.vector.x,
      y = self.vector.y
    })
    self._d = Coord:new({
      x = o.d.x + o.w * math.sign(o.vector.x),
      y = self._d.y
    })
    self.d = self._d:round()
    self:_addColState(colStates.PUSH_1DX)
  end,

  pushY = function (self, o)
    self.vector = Vector:new({
      x = self.vector.x,
      y = o.vector.y
    })
    self._d = Coord:new({
      x = self._d.x,
      y = o.d.y + o.h * math.sign(o.vector.y),
    })
    self.d = self._d:round()
    self:_addColState(colStates.PUSH_1DY)
  end
})

local ICollideBlock = Trait:new({
  _resolve = function (self, o)
    if (
      o.vector.x > 0 and -- moving right
      o.d.x + o.w < self.d.x + self.w / 2 -- from the left
    )
      or
    (
      o.vector.x < 0 and -- moving left
      o.d.x > self.d.x + self.w / 2 -- from the right
    ) then
      o.d.x = self.d.x + (self.w * -math.sign(o.vector.x))
      o.vector = Vector:new({
        x = 0,
        y = o.vector.y
      })
    end
    if (
      o.vector.y > 0 and -- moving down
      o.d.y + o.h < self.d.y + self.h / 2 -- from top
    )
      or
    (
      o.vector.y < 0 and -- moving up
      o.d.y > self.d.y + self.h / 2 -- from under
    ) then
      o.d.y = self.d.y + (self.h * -math.sign(o.vector.y))
      o.vector = Vector:new({
        x = o.vector.x,
        y = 0
      })
    end
    return true
  end
})

return function () return IACollide, ICollideBlock end