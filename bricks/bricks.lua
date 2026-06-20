local COLOR, _, _, MOVE, STYLE = require("Const")()
local AGameUIObject = require("Utils")()
local _, _, _, Vector = require("Couple")()
local _, IRectFill, IRectLine, rectangle = require("Draw")()
local moveVectors, _, _, _, IMoveX, _ = require("Move")()
local _, ICollideBlocker, _, _, _, ICollidePusher = require("Collide")()
local _, _, _, IControlMove = require("Control")()

local debug = require("Debug")()

local function bricks()
  -- The ball move
  local AutoBounce = {
    autoVector = moveVectors[MOVE.UP]:copy() + moveVectors[MOVE.RIGHT]:copy(),
    _hit = function(self, id, _, _, vector)
      if vector then
        local x = self.autoVector.x
        if vector.x ~= 0 then
          x = x * math.sign(x) * math.sign(vector.x)
        end
        local y = self.autoVector.y
        if vector.y ~= 0 then
          y = y * math.sign(y) * math.sign(vector.y)
        end
        self.autoVector = Vector:new({
          x = x,
          y = y,
        })
        return true
      else
        return false
      end
    end,
    _move = function(self, id, _, _, _)
      return self.autoVector:copy()
    end,
  }

  -- the falling bonus move
  local Fall = {
    _time = 0,
    _update = function(self, _, dt)
      self._time = self._time + dt
      if self._time > 0.2 then
        self.speed = self.speed + 9
        self._time = self._time - 0.2
      end
    end,
    _move = function(self, id, _, _)
      return moveVectors[MOVE.DOWN]:copy()
    end
  }

  local BRICK_HEALTH = 100
  local BONUS_HEALTH = 100

  -- health driven brick drawing
  local Wear = {
    _draw = function(self)
      love.graphics.setColor({ self.health / BRICK_HEALTH, self.health / BRICK_HEALTH, self.health / BRICK_HEALTH })
      rectangle(self, STYLE.FILL)
    end
  }

  local Boundary = AGameUIObject:new(ICollideBlocker, IRectFill)
  local Bonus = AGameUIObject:new(IControlMove, IRectFill, Fall, {
    color = COLOR.BLUE
  })
  local BonusGenerator = {
    _destroy = function(self, id, who, by, vector)
      local c = self:c()
      local bonus = Bonus:new({
        id = "bonus",
        x = c.x,
        y = c.y,
        w = 45,
        h = 35,
        health = BONUS_HEALTH,
        speed = 0,
        vector = moveVectors[MOVE.DOWN]:copy()
      })
      self.eventManager:addObjects(bonus)
    end
  }
  local Bat = AGameUIObject:new(IControlMove, IMoveX, ICollideBlocker, ICollidePusher, IRectLine)
  local Brick = AGameUIObject:new(IControlMove, ICollideBlocker, IRectFill, Wear, BonusGenerator)
  local Ball = AGameUIObject:new(IControlMove, AutoBounce, ICollidePusher, IRectLine, {
    _getDamage = function(_, target)
      local damage = {
        brick = 51,
      }
      if target.id then
        return damage[target.id] or 0
      end
    end,
  })


  local bat = Bat:new({
    id = "bat",
    x = 200,
    y = 580,
    w = 150,
    h = 10,
    speed = 400,
    vector = moveVectors[MOVE.NONE]:copy(),
    color = COLOR.CYAN,
  })

  local ball = Ball:new({
    id = "ball",
    x = 400,
    y = 300,
    w = 10,
    h = 10,
    health = 100,
    speed = 240,
    vector = moveVectors[MOVE.NONE]:copy(),
    color = COLOR.YELLOW,
  }, AutoBounce)

  local objects = {
    bat,
    ball,
    Boundary:new({
      id = "ceil",
      x = 0,
      y = 0,
      w = 800,
      h = 3,
    }),
    Boundary:new({
      id = "left",
      x = 0,
      y = 3,
      w = 3,
      h = 597,
    }),
    Boundary:new({
      id = "right",
      x = 797,
      y = 3,
      w = 3,
      h = 597,
    }),
    Boundary:new({
      id = "floor",
      x = 3,
      y = 597,
      w = 794,
      h = 3,
      color = COLOR.RED,
      _getDamage = function(_, target)
        local damage = {
          ball = BRICK_HEALTH + 1,
          bonus = BONUS_HEALTH + 1
        }
        if target.id then
          return damage[target.id] or 0
        end
      end,
    }),
  }
  for x = 50, 700, 50 do
    for y = 10, 210, 40 do
      table.insert(
        objects,
        Brick:new({
          id = "brick",
          health = BRICK_HEALTH,
          x = x,
          y = y,
          w = 45,
          h = 35,
        })
      )
    end
  end

  return objects
end

return bricks
