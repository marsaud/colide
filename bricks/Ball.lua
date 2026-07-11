local GAME = require("bricks.GAME")

local MOVE = require("Const").MOVE
local ICollidePusher = require("Collide").ICollidePusher
local IControlMove = require("Control").IControlMove
local Vector = require("Couple").Vector
local IRectLine = require("Draw").IRectLine
local moveVectors = require("Move").moveVectors
local AGameUIObject = require("Utils").AGameUIObject

-- The ball move
local BallAutoBounce = {
  autoVector = moveVectors[MOVE.UP]:copy() + moveVectors[MOVE.RIGHT]:copy(),
  _hit = function(self, id, _who, _by, vector)
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
  _move = function(self, id, _ctrl, _dt, _v)
    return self.autoVector:copy()
  end,
}

local Ball = AGameUIObject:new(IControlMove, BallAutoBounce, ICollidePusher, IRectLine, {
  _getDamage = function(_, target)
    local damage = {
      [GAME.ID.BRICK] = GAME.HEALTH.BASE + 1,
    }
    return damage[target.id] or 0
  end,
})

return {
  Ball = Ball,
  HEALTH = GAME.HEALTH.BASE,
}
