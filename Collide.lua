require("math-ext")
local _, Trait = require("POO")()
local Coord, _, _, Vector = require("Couple")()
local EVENT, _ = require("Event")()
-- local debug = require("Debug")()

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

  resolve = function (self, o, ...)
    local effect = false
    local skip = o == self
    skip = skip or not o.IACollide
    skip = skip or self:_isRight(o)
    skip = skip or self:_isLeft(o)
    skip = skip or self:_isUnder(o)
    skip = skip or self:_isTop(o)
    if not skip then
      effect = self:_resolve(o, ...)
    end
    return effect
  end,

  _resolve = function (_, _)
    return false
  end,

  blockX = function (self, _, prevPusher, ...)
    self.vector.x = 0
    self._d = Coord:new({
      x = self._c.x,
      y = self._d.y
    })
    self.d = self._d:round()
    if prevPusher then
      return prevPusher:blockX(self, ...)
    else
      return true
    end
  end,

  blockY = function (self, _, prevPusher, ...)
    local _ = {...}
    self.vector.y = 0
    self._d = Coord:new({
      x = self._d.x,
      y = self._c.y
    })
    self.d = self._d:round()
    if prevPusher then
      return prevPusher:blockY(self, ...)
    else
      return true
    end
  end,

  pushX = function (self, by, ...)
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
      if self.eventManager then
        return self.eventManager:fire(EVENT.MOVE, self, by, ...)
      else
        return true
      end
    else
      return false
    end
  end,

  pushY = function (self, by, ...)
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
      if self.eventManager then
        return self.eventManager:fire(EVENT.MOVE, self, by, ...)
      else
        return true
      end
    else
      return false
    end
  end
})

local _blockPushX = function (self, by, ...)
  return by:blockX(self, ...)
end

local _blockPushY = function (self, by, ...)
  return by:blockY(self, ...)
end

local ICollideBlocker = Trait:new({
  pushX = _blockPushX,
  pushY = _blockPushY
})

local ICollideBlockerX = Trait:new({
  pushX = _blockPushX
})

local ICollideBlockerY = Trait:new({
  pushY = _blockPushY
})

local ICollidePusher = Trait:new({
  _resolve = function (self, o, ...)
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
    local effect = false
    if effectX then
      if self.eventManager then
        self.eventManager:fire(EVENT.HIT, self, Vector:new({
          x = -1,
          y = 1
        }))
        self.eventManager:fire(EVENT.HIT, o, Vector:new({
          x = math.sign(self.vector.x) * math.sign(o.vector.x),
          y = 1
        }))
      end
      effect = o:pushX(self, ...) or effect
    end
    if effectY then
      if self.eventManager then
        self.eventManager:fire(EVENT.HIT, self, Vector:new({
          x = 1,
          y = -1
        }))
        self.eventManager:fire(EVENT.HIT, o, Vector:new({
          x = 1,
          y = math.sign(self.vector.y) * math.sign(o.vector.y)
        }))
      end
      effect = o:pushY(self, ...) or effect
    end
    return effect
  end
})

local ICollideNot = Trait:new()

return function () return
  IACollide,
  ICollideBlocker,
  ICollideBlockerX,
  ICollideBlockerY,
  ICollideNot,
  ICollidePusher
end