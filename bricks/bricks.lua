local COLOR, _, _, MOVE = require("Const")()
local AGameUIObject = require("Utils")()
local _, _, _, Vector = require("Couple")()
local _, IRectFill, IRectLine = require("Draw")()
local moveVectors, _, _, IMoveNot, IMoveX, _ = require("Move")()
local _, ICollideBlocker, _, _, _, ICollidePusher = require("Collide")()
local _, _, _, IControlMove = require("Control")()

local helpers = require("helpers")
local ICollapse = helpers.ICollapse

local function bricks()
  local AutoBounce = {
    autoVector = moveVectors[MOVE.UP]:copy() + moveVectors[MOVE.RIGHT]:copy(),
    _hit = function(self, _, _, vector)
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
    _move = function(self, _, _, _)
      return self.autoVector:copy()
    end,
  }

  local RectStatic = AGameUIObject:new(IMoveNot, ICollideBlocker, ICollidePusher, IRectFill)
  local Bat = AGameUIObject:new(IControlMove, IMoveX, ICollideBlocker, ICollidePusher)
  local Brick = AGameUIObject:new(IMoveNot, ICollideBlocker, ICollapse, IRectFill)
  local Ball = AGameUIObject:new(IControlMove, AutoBounce, ICollidePusher, ICollapse, IRectLine, {
    getHit = function(_, _)
      return 50
    end,
  })
  Ball:addPlugin("_hit", ICollapse._hit)

  local bat = Bat:new({
    id = "bat",
    x = 200,
    y = 580,
    w = 150,
    h = 10,
    speed = 400,
    vector = moveVectors[MOVE.NONE]:copy(),
    color = COLOR.CYAN,
  }, IRectLine)

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
    RectStatic:new({
      id = "ceil",
      x = 0,
      y = 0,
      w = 800,
      h = 3,
    }),
    RectStatic:new({
      id = "left",
      x = 0,
      y = 3,
      w = 3,
      h = 597,
    }),
    RectStatic:new({
      id = "right",
      x = 797,
      y = 3,
      w = 3,
      h = 597,
    }),
    RectStatic:new({
      id = "floor",
      x = 3,
      y = 597,
      w = 794,
      h = 3,
      color = COLOR.RED,
      getHit = function(_, who)
        if who and who.id == "ball" then
          return 100
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
          health = 50,
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
