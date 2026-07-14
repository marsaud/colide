require("math-ext")
local Couple = require("Couple")
local Coord, Vector = Couple.Coord, Couple.Vector
local C = require("Const")
local EVENT = C.EVENT
-- local debug = require("Debug").debug

local IACollide = {
  _constructors = {
    IACollide = function(self)
      self._whiteList = {}
      self._whiteListN = 0
      self._blackList = {}
      self._blackListN = 0
    end,
  },
  _isRight = function(self, o)
    return self:d().x >= (o:d().x + o.w)
  end,
  _isLeft = function(self, o)
    return (self:d().x + self.w) <= o:d().x
  end,
  _isUnder = function(self, o)
    return self:d().y >= (o:d().y + o.h)
  end,
  _isTop = function(self, o)
    return (self:d().y + self.h) <= o:d().y
  end,

  whiteList = function(self, list)
    if list ~= nil then
      self._whiteList = {}
      self._whiteListN = 0
      for _, id in pairs(list) do
        self._whiteList[id] = true
        self._whiteListN = self._whiteListN + 1
      end
    end
    return self._whiteList
  end,

  blackList = function(self, list)
    if list ~= nil then
      self._blackList = {}
      for _, id in pairs(list) do
        self._blackList[id] = true
      end
    end
    return self._blackList
  end,

  welcome = function(self, o)
    if self._blackList[o.id] == true then
      return false
    end
    return self._whiteListN == 0 or self._whiteList[o.id] == true
  end,

  -- analyse how "o" will react on self on collision
  resolve = function(self, id, o, ...)
    local effect = false
    local skip = o == self
    skip = skip or not o._resolve
    skip = skip or not o:welcome(self) or not self:welcome(o)
    local previous = { ... }
    for _, _o in ipairs(previous) do
      if self == _o then
        skip = true
        break
      end
    end
    skip = skip or o:_isRight(self)
    skip = skip or o:_isLeft(self)
    skip = skip or o:_isUnder(self)
    skip = skip or o:_isTop(self)
    if not skip then
      effect = o:_resolve(id, self, ...)
    end
    return effect
  end,

  _resolve = function(_, _, _)
    return false
  end,

  blockX = function(self, id, _, prevPusher, ...)
    self:v(Vector:new({ x = 0, y = self:v().y }), true)
    self:d(Coord:new({ x = self:c().x, y = self:d().y }), true)
    if prevPusher then
      return prevPusher:blockX(id, self, ...)
    else
      return true
    end
  end,

  blockY = function(self, id, _, prevPusher, ...)
    self:v(Vector:new({ x = self:v().x, y = 0 }), true)
    self:d(Coord:new({ x = self:d().x, y = self:c().y }), true)
    if prevPusher then
      return prevPusher:blockY(id, self, ...)
    else
      return true
    end
  end,

  pushX = function(self, id, by, ...)
    local force = self.group and self.group ~= by.group
    self:v(Vector:new({ x = by:v().x, y = self:v().y }), force)
    -- penetration
    local _x
    if by:v().x < 0 then -- moving left
      _x = by:d().x - self.w
    else
      _x = by:d().x + by.w
    end
    if _x ~= self:d().x then
      self:d(Coord:new({ x = _x, y = self:d().y }), force)
      return self:fireMove(id, by, ...)
    else
      return false
    end
  end,

  pushY = function(self, id, by, ...)
    local force = self.group and self.group ~= by.group
    self:v(Vector:new({ x = self:v().x, y = by:v().y }), force)
    -- penetration
    local _y
    if by:v().y < 0 then -- moving up
      _y = by:d().y - self.h
    else
      _y = by:d().y + by.h
    end
    if _y ~= self:d().y then
      self:d(Coord:new({ x = self:d().x, y = _y }), force)
      return self:fireMove(id, by, ...)
    else
      return false
    end
  end,
}

local _blockPushX = function(self, id, by, ...)
  return by:blockX(id, self, ...)
end

local _blockPushY = function(self, id, by, ...)
  return by:blockY(id, self, ...)
end

local ICollideBlocker = {
  pushX = _blockPushX,
  pushY = _blockPushY,
}

local ICollideBlockerX = {
  pushX = _blockPushX,
}

local ICollideBlockerY = {
  pushY = _blockPushY,
}

local ICollidePusher = {
  _resolve = function(self, id, o, ...)
    if o._group then
      return false
    end
    local effectX = false
    local effectY = false
    if
      (not o:_isTop(self) and not o:_isUnder(self))
      and (
        (
          self:v().x > 0 -- moving right
          and self:d().x + self.w / 2 <= o:d().x + o.w / 2 -- from the left
        )
        or (
          self:v().x < 0 -- moving left
          and self:d().x + self.w / 2 > o:d().x + o.w / 2 -- from the right
        )
      )
    then
      effectX = true
    end

    if
      (not o:_isRight(self) and not o:_isLeft(self))
      and (
        (
          self:v().y > 0 -- moving down
          and self:d().y + self.h / 2 <= o:d().y + o.h / 2 -- from top
        )
        or (
          self:v().y < 0 -- moving up
          and self:d().y + self.h > o:d().y + o.h / 2 -- from under
        )
      )
    then
      effectY = true
    end

    if effectX and effectY then
      local intX = math.min(self:d().x + self.w - o:d().x, self.w, o.w, o:d().x + o.w - self:d().x)
      local intY = math.min(self:d().y + self.h - o:d().y, self.h, o.h, o:d().y + o.h - self:d().y)
      if intX > intY then
        effectX = false
      elseif intY > intX then
        effectY = false
      end
    end
    local effect = false
    if effectX then
      if self.eventManager then
        self.eventManager:fire(
          EVENT.HIT,
          id,
          self,
          o,
          Vector:new({
            x = -math.sign(self:v().x),
            y = 0,
          })
        )
        self.eventManager:fire(
          EVENT.HIT,
          id,
          o,
          self,
          Vector:new({
            x = math.sign(self:v().x),
            y = 0,
          })
        )
      end
      effect = o:pushX(id, self, ...) or effect
    end
    if effectY then
      if self.eventManager then
        self.eventManager:fire(
          EVENT.HIT,
          id,
          self,
          o,
          Vector:new({
            x = 0,
            y = -math.sign(self:v().y),
          })
        )
        self.eventManager:fire(
          EVENT.HIT,
          id,
          o,
          self,
          Vector:new({
            x = 0,
            y = math.sign(self:v().y),
          })
        )
      end
      effect = o:pushY(id, self, ...) or effect
    end
    return effect
  end,
}

local ICollideNot = {}

return {
  IACollide = IACollide,
  ICollideBlocker = ICollideBlocker,
  ICollideBlockerX = ICollideBlockerX,
  ICollideBlockerY = ICollideBlockerY,
  ICollideNot = ICollideNot,
  ICollidePusher = ICollidePusher,
}
