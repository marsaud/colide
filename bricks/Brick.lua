local GAME = require("bricks.GAME")

local STYLE = require("Const").STYLE
local ICollideBlocker = require("Collide").ICollideBlocker
local Draw = require("Draw")
local IRectFill, rectangle = Draw.IRectFill, Draw.rectangle
local AGameUIObject = require("AGameUIObject").AGameUIObject

local BRICK_HEALTH = GAME.HEALTH.BASE * 2

-- health driven brick drawing
local IDRawBrick = {
  _draw = function(self)
    local cLevel = self:valHealth() / BRICK_HEALTH
    love.graphics.setColor({ cLevel, cLevel, cLevel })
    rectangle(self, STYLE.FILL)
  end,
}

local Brick = AGameUIObject:extend(ICollideBlocker, IRectFill, IDRawBrick)

return {
  Brick = Brick,
  HEALTH = BRICK_HEALTH,
}
