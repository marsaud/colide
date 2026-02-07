require("math-ext")
local _, Trait = require("POO")()
local Coord, _, _, Vector = require("Couple")()

local IACollide = Trait:new({
  IACollide = true,
  _isRight = function (self, o)
    return self.d.x >= (o.d.x + o.w)
  end,
  _isLeft = function (self, o)
    return (self.d.x + self.w) <= o.d.x
  end,
  _isUnder = function (self, o)
    return self.d.y >= (o.d.y + o.h)
  end,
  _isTop = function (self, o)
    return (self.d.y + self.h) <= o.d.y
  end,
  process = function (self, objects)
    if self:submitColliders(objects) then
      return self:resolve(objects)
    end
  end,
  submitColliders = function (self, objects)
    if not self._colliders then
      self._colliders = {}
    end
    local submitted = false
    for _, o in ipairs(objects) do
      local skip = o == self
      skip = skip or not o.IACollide
      skip = skip or self:_isRight(o)
      skip = skip or self:_isLeft(o)
      skip = skip or self:_isUnder(o)
      skip = skip or self:_isTop(o)
      if not skip then
        table.insert(self._colliders, o)
        submitted = true
      end
    end
    return submitted
  end,
  resolve = function (self, objects)
    if (#self._colliders < 1) then
      return
    end
    table.sort(self._colliders, function (o1, o2)
      return o1.priority < o2.priority
    end)
    local o = table.remove(self._colliders)
    while o do
      if self:_resolve(o) then
        o:process(objects)
      end
      o = table.remove(self._colliders)
    end
  end,

  flushCollisionStates = function (self)
    self._byXs = {}
    self._byYs = {}
  end,

  _storeByX = function (self, o)
    if not self._byXs then
      self._byXs = {}
    end
    table.insert(self._byXs, o)
  end,
  _storeByY = function (self, o)
    if not self._byYs then
      self._byYs = {}
    end
    table.insert(self._byYs, o)
  end,
  _popByX = function (self)
    if self._byXs then
      return table.remove(self._byXs)
    end
  end,
  _popByY = function (self)
    if self._byYs then
      return table.remove(self._byYs)
    end
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
    local pushBy = self:_popByX()
    if pushBy then
      pushBy:blockX(self)
    end
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
    local pushBy = self:_popByY()
    if pushBy then
      pushBy:blockY(self)
    end
  end,

  pushX = function (self, ...)
    local bys = {...}
    local by = table.remove(bys)
    self:_storeByX(by)
    self.vector = Vector:new({
      x = by.vector.x,
      y = self.vector.y
    })
    local _x
    if (math.sign(by.vector.x) < 0) then -- moving left
      _x = by.d.x - self.w
    else
      _x = by.d.x + by.w
    end
    self._d = Coord:new({
      x = _x,
      y = self._d.y
    })
    self.d = self._d:round()
  end,

  pushY = function (self, ...)
    local bys = {...}
    local by = table.remove(bys)
    self:_storeByY(by)
    self.vector = Vector:new({
      x = self.vector.x,
      y = by.vector.y
    })
    local _y
    if (math.sign(by.vector.y) < 0) then -- moving up
      _y = by.d.y - self.h
    else
      _y = by.d.y + by.h
    end
    self._d = Coord:new({
      x = self._d.x,
      y = _y
    })
    self.d = self._d:round()
  end
})

local ICollideBlock = Trait:new({
  priority = 100,
  _resolve = function ()
    return false
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
  priority = 50,
  _resolve = function (self, o)
    local effect = false
    if (not o:_isTop(self) and not o:_isUnder(self))
    and
    ((
      self.vector.x > 0 and -- moving right
      self.d.x + self.w < o.d.x + o.w / 2 -- from the left
    )
      or
    (
      self.vector.x < 0 and -- moving left
      self.d.x > o.d.x + o.w / 2 -- from the right
    )) then
        effect = true
        o:pushX(self)
    end
    if (not o:_isRight(self) and not o:_isLeft(self))
    and
    ((
      self.vector.y > 0 and -- moving down
      self.d.y + self.h < o.d.y + o.h / 2 -- from top
    )
      or
    (
      self.vector.y < 0 and -- moving up
      self.d.y > o.d.y + o.h / 2 -- from under
    )) then
        effect = true
        o:pushY(self)
    end
    return effect
  end
})

local ICollideNot = Trait:new({
  priority = 25,
  _resolve = function () return false end
})

return function () return
  IACollide,
  ICollideBlock,
  ICollideNot,
  ICollidePush
end