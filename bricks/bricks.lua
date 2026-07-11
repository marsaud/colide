local C = require("Const")
local COLOR, MOVE = C.COLOR, C.MOVE
local ICollideBlocker = require("Collide").ICollideBlocker
local IRectFill = require("Draw").IRectFill
local moveVectors = require("Move").moveVectors
local AGameUIObject = require("Utils").AGameUIObject

-- local debug = require("Debug").debug

local GAME = require("bricks.GAME")

local BL = require("bricks.Ball")
local Ball, BALL_HEALTH = BL.Ball, BL.HEALTH
local Bat = require("bricks.Bat").Bat
local BR = require("bricks.Brick")
local Brick, BRICK_HEALTH = BR.Brick, BR.HEALTH
local BrickFallGenerator = require("bricks.BrickFall").BrickFallGenerator

local Boundary = AGameUIObject:new(ICollideBlocker, IRectFill)

local function bricks()
  local bat = Bat:new({
    id = GAME.ID.BAT,
    x = 200,
    y = 580,
    w = 150,
    h = 10,
    speed = 400,
    vector = moveVectors[MOVE.NONE]:copy(),
    color = COLOR.CYAN,
  })

  local ball = Ball:new({
    id = GAME.ID.BALL,
    x = 400,
    y = 300,
    w = 10,
    h = 10,
    health = BALL_HEALTH,
    speed = 240,
    vector = moveVectors[MOVE.NONE]:copy(),
    color = COLOR.YELLOW,
  })

  local objects = {
    bat,
    ball,
    Boundary:new({
      id = GAME.ID.BOUND_CLOSE,
      x = 0,
      y = 0,
      w = 800,
      h = 3,
    }),
    Boundary:new({
      id = GAME.ID.BOUND_CLOSE,
      x = 0,
      y = 3,
      w = 3,
      h = 597,
    }),
    Boundary:new({
      id = GAME.ID.BOUND_CLOSE,
      x = 797,
      y = 3,
      w = 3,
      h = 597,
    }),
    Boundary:new({
      id = GAME.ID.BOUND_OUT,
      x = 3,
      y = 597,
      w = 794,
      h = 3,
      color = COLOR.RED,
      _getDamage = function(_self, target)
        local damage = {
          [GAME.ID.BALL] = GAME.DAMAGE.LETHAL,
          -- [GAME.ID.BRICKFALL] = GAME.DAMAGE.LETHAL,
        }
        return damage[target.id] or 0
      end,
    }),
  }
  for x = 50, 700, 50 do
    for y = 10, 210, 40 do
      table.insert(
        objects,
        Brick:new({
          id = GAME.ID.BRICK,
          health = BRICK_HEALTH,
          x = x,
          y = y,
          w = 45,
          h = 35,
        }, BrickFallGenerator)
      )
    end
  end

  return objects
end

return bricks
