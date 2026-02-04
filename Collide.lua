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
  _byXs = {},
  _byYs = {},
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

  blockX = function (self, ...)
    local _ = {...}
    self.vector = Vector:new({
      x = 0,
      y = self.vector.y
    })
    self._d = Coord:new({
      x = self._c.x,
      y = self._d.y
    })
    self.d = self._d:round()
    local pushBy = table.remove(self._byXs)
    if pushBy then
      pushBy.blockX(self)
    end
    self:_addColState(colStates.BLOCK_1DX)
  end,

  blockY = function (self, ...)
    local _ = {...}
    self.vector = Vector:new({
      x = self.vector.x,
      y = 0
    })
    self._d = Coord:new({
      x = self._d.x,
      y = self._c.y
    })
    self.d = self._d:round()
    local pushBy = table.remove(self._byYs)
    if pushBy then
      pushBy.blockY(self)
    end
    self:_addColState(colStates.BLOCK_1DY)
  end,

  pushX = function (self, ...)
    local bys = {...}
    local by = table.remove(bys)
    table.insert(self._byXs, by)
    self.vector = Vector:new({
      x = by.vector.x,
      y = self.vector.y
    })
    self._d = Coord:new({
      x = by.d.x + by.w * math.sign(by.vector.x),
      y = self._d.y
    })
    self.d = self._d:round()
    self:_addColState(colStates.PUSH_1DX)
  end,

  pushY = function (self, ...)
    local bys = {...}
    local by = table.remove(bys)
    table.insert(self._byYs, by)
    self.vector = Vector:new({
      x = self.vector.x,
      y = by.vector.y
    })
    self._d = Coord:new({
      x = self._d.x,
      y = by.d.y + by.h * math.sign(by.vector.y),
    })
    self.d = self._d:round()
    self:_addColState(colStates.PUSH_1DY)
  end
})

local ICollideBlock = Trait:new({
  _resolve = function (self, o)
    -- if (
    --   o.vector.x > 0 and -- moving right
    --   o.d.x + o.w < self.d.x + self.w / 2 -- from the left
    -- )
    --   or
    -- (
    --   o.vector.x < 0 and -- moving left
    --   o.d.x > self.d.x + self.w / 2 -- from the right
    -- ) then
    --     o:blockX(self)
    -- end
    -- if (
    --   o.vector.y > 0 and -- moving down
    --   o.d.y + o.h < self.d.y + self.h / 2 -- from top
    -- )
    --   or
    -- (
    --   o.vector.y < 0 and -- moving up
    --   o.d.y > self.d.y + self.h / 2 -- from under
    -- ) then
    --     o:blockY(self)
    -- end
    return true
  end,

  pushX = function (self, ...)
    local bys = {...}
    local by = table.remove(bys)
    by:blockX(self)
  end,

  pushY = function (self, ...)
    local bys = {...}
    local by = table.remove(bys)
    by:blockY(self)
  end
})

local ICollidePush = Trait:new({
    _resolve = function (self, o)
    if (
      self.vector.x > 0 and -- moving right
      self.d.x + self.w < o.d.x + o.w / 2 -- from the left
    )
      or
    (
      self.vector.x < 0 and -- moving left
      self.d.x > o.d.x + o.w / 2 -- from the right
    ) then
        o:pushX(self)
    end
    if (
      self.vector.y > 0 and -- moving down
      self.d.y + self.h < o.d.y + o.h / 2 -- from top
    )
      or
    (
      self.vector.y < 0 and -- moving up
      self.d.y > o.d.y + o.h / 2 -- from under
    ) then
        o:pushY(self)
    end
    return true
  end
})

local ICollideNot = Trait:new({
  _resolve = function () return true end
})

return function () return
  IACollide,
  ICollideBlock,
  ICollideNot,
  ICollidePush
end