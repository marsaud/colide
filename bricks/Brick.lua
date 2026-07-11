local GAME = require("bricks.GAME")

local STYLE = require("Const").STYLE
local ICollideBlocker = require("Collide").ICollideBlocker
local Draw = require("Draw")
local IRectFill, rectangle = Draw.IRectFill, Draw.rectangle
local AGameUIObject = require("Utils").AGameUIObject

local BRICK_HEALTH = GAME.HEALTH.BASE * 2

-- health driven brick drawing
local IDRawBrick = {
  _draw = function(self)
    love.graphics.setColor({
      self.health / BRICK_HEALTH,
      self.health / BRICK_HEALTH,
      self.health / BRICK_HEALTH,
    })
    rectangle(self, STYLE.FILL)
  end,
}

local Brick = AGameUIObject:new(ICollideBlocker, IRectFill, IDRawBrick)

return {
  Brick = Brick,
  HEALTH = BRICK_HEALTH,
}
