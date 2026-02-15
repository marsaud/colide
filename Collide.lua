require("math-ext")
local _, Trait = require("POO")()
local Coord, _, _, _ = require("Couple")()

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
  rresolve = function (self, o)
    if self == o then return false end
    if not o.IACollide then return false end
    if self:_isRight(o) then return false end
    if self:_isLeft(o) then return false end
    if self:_isUnder(o) then return false end
    if self:_isTop(o) then return false end
    return self:_resolve(o)
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

  _resolve = function (_, _)
    return false
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
    self.vector.x = 0
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
    self.vector.y = 0
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
    self.vector.x = by.vector.x

    -- penetration
    local _x
    if (math.sign(by.vector.x) < 0) then -- moving left
      _x = by.d.x - self.w
    else
      _x = by.d.x + by.w
    end
    if _x ~= self._d.x then
      self._d.x = _x
      self.d = self._d:round()
    end
  end,

  pushY = function (self, ...)
    local bys = {...}
    local by = table.remove(bys)
    self:_storeByY(by)
    self.vector.y = by.vector.y

    -- penetration
    local _y
    if (math.sign(by.vector.y) < 0) then -- moving up
      _y = by.d.y - self.h
    else
      _y = by.d.y + by.h
    end
    if _y ~= self._d.y then
      self._d.y = _y
      self.d = self._d:round()
    end
  end
})

local _blockPushX = function (self, ...)
  local bys = {...}
  local by = table.remove(bys)
  by:blockX(self)
end

local _blockPushY = function (self, ...)
  local bys = {...}
  local by = table.remove(bys)
  by:blockY(self)
end

local ICollideBlocker = Trait:new({
  priority = 100,
  pushX = _blockPushX,
  pushY = _blockPushY
})

local ICollideBlockerX = Trait:new({
  priority = 80,
  pushX = _blockPushX
})

local ICollideBlockerY = Trait:new({
  priority = 80,
  pushY = _blockPushY
})

local ICollidePusher = Trait:new({
  priority = 50,
  _resolve = function (self, o)
    local effectX = false
    local effectY = false
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
        effectX = true
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
        effectY = true
    end

    if effectX and effectY then
      local intX = math.min(
        self.d.x + self.w - o.d.x,
        self.w,
        o.w,
        o.d.x + o.w - self.d.x

      )
      local intY = math.min(
        self.d.y + self.h - o.d.y,
        self.h,
        o.h,
        o.d.y + o.h - self.d.y
      )
      if intX > intY then
        effectX = false
      elseif intY > intX then
        effectY = false
      end
    end

    if effectX then o:pushX(self) end
    if effectY then o:pushY(self) end

    return effectX or effectY
  end
})

local ICollideNot = Trait:new({
  priority = 25
})

return function () return
  IACollide,
  ICollideBlocker,
  ICollideBlockerX,
  ICollideBlockerY,
  ICollideNot,
  ICollidePusher
end