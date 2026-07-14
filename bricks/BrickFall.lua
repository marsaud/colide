local GAME = require("bricks.GAME")

local C = require("Const")
local COLOR, MOVE = C.COLOR, C.MOVE
local Control = require("Control")
local ICollidePusher = require("Collide").ICollidePusher
local IControlMove = Control.IControlMove
local Draw = require("Draw")
local IRectFill = Draw.IRectFill
local moveVectors = require("Move").moveVectors
local AGameUIObject = require("Utils").AGameUIObject

local BRICKFALL_HEALTH = 100

-- the falling brick move
local BrickFallMove = {
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
  end,
  _hit = function(self, _id, who, by, _vector)
    if
      who.id == GAME.ID.BAT
      or who.id == GAME.ID.BOUND_CLOSE
      or by.id == GAME.ID.BAT
      or by.id == GAME.ID.BOUND_CLOSE
    then
      self.speed = 0
    end
  end,
}

local BrickFall = AGameUIObject:new(IControlMove, BrickFallMove, ICollidePusher, IRectFill, {
  color = COLOR.BLUE,
})

local BrickFallGenerator = {
  _destroy = function(self, _id, _who, _by, _vector)
    local c = self:c()
    local brickFall = BrickFall:new({
      id = GAME.ID.BRICKFALL,
      x = c.x,
      y = c.y,
      w = 45,
      h = 35,
      health = BRICKFALL_HEALTH,
      speed = 0,
      vector = moveVectors[MOVE.DOWN]:copy(),
    })
    brickFall:blackList({ GAME.ID.BRICK })
    self.eventManager:addObjects(brickFall)
  end,
}

return {
  BrickFall = BrickFall,
  BrickFallGenerator = BrickFallGenerator,
}
