local COLOR, _, _, MOVE = require("Const")()
local AGameUIObject = require("Utils")()
local _, _, _, Vector = require("Couple")()
local _, IRectFill, IRectLine = require("Draw")()
local
		moveVectors,
		_,
		IMove,
		IMoveNot,
		IMoveX,
		IMoveY = require("Move")()
	local
		_,
		ICollideBlocker,
		_,
		_,
		_,
		ICollidePusher = require("Collide")()

local function demo ()
  local Rect2D = AGameUIObject:new(IMove, ICollidePusher, IRectLine)
  local RectPassive = AGameUIObject:new (IMoveNot, ICollidePusher, IRectLine)
  local Rect1DX = AGameUIObject:new(IMoveX, ICollidePusher, IRectLine)
  local Rect1DY = AGameUIObject:new(IMoveY, ICollidePusher, IRectLine)
  local RectStatic = AGameUIObject:new(IMoveNot, ICollideBlocker, ICollidePusher, IRectFill)

  local AutoMove = {
    stateIndex = 1,
    stateTimer = 0,
    states = {
      moveVectors[MOVE.UP],
      moveVectors[MOVE.RIGHT],
      moveVectors[MOVE.DOWN],
      moveVectors[MOVE.LEFT],
    },
    getMove = function (self, _, _, dt)
      self.stateTimer = self.stateTimer + dt
      if self.stateTimer > 2 then
        self.stateTimer = 0
        self.stateIndex = self.stateIndex + 1
        if self.stateIndex > #self.states then
          self.stateIndex = 1
        end
      end
      return self.states[self.stateIndex]:copy()
    end
  }

  local AutoBounce = {
    autoVector = moveVectors[MOVE.UP]:copy() + moveVectors[MOVE.RIGHT]:copy(),
    _hit = function (self, _, _, vector)
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
          y = y
        })
        return true
      else
        return false
      end
    end,
    getMove = function (self, _, _, _)
      return self.autoVector:copy()
    end
  }

  local rect1 = Rect2D:new({
    id = 'red',
    x = 25,
    y = 300,
    w = 50,
    h = 50,
    speed = 120,
    vector = moveVectors[MOVE.NONE]:copy(),
    color = COLOR.RED
  })

  local rect2 = Rect1DX:new({
    id = 'green',
    x = 125,
    y = 300,
    w = 140,
    h = 100,
    speed = 50,
    vector = moveVectors[MOVE.NONE]:copy(),
    color = COLOR.GREEN
  }, IMoveX, ICollidePusher, IRectLine)

  local rect3 = Rect1DY:new({
    id = 'blue',
    x = 265,
    y = 300,
    w = 110,
    h = 25,
    speed = 40,
    vector = moveVectors[MOVE.NONE]:copy(),
    color = COLOR.BLUE
  }, IMoveY, ICollidePusher, IRectLine)

  local rect4 = RectPassive:new({
    id = 'magenta',
    x = 385,
    y = 300,
    w = 40,
    h = 120,
    speed = 90,
    vector = moveVectors[MOVE.NONE]:copy(),
    color = COLOR.MAGENTA
  })

  local rect5 = Rect2D:new({
    id = 'yellow',
    x = 505,
    y = 300,
    w = 60,
    h = 90,
    speed = 110,
    vector = moveVectors[MOVE.NONE]:copy(),
    color = COLOR.YELLOW
  }, AutoMove)

  local rect6 = RectStatic:new({
    id = 'cyan',
    x = 625,
    y = 300,
    w = 100,
    h = 100,
    speed = 110,
    vector = moveVectors[MOVE.NONE]:copy(),
    color = COLOR.CYAN
  })

  local rect7 = Rect2D:new({
    id = 'bouncer',
    x = 25,
    y = 400,
    w = 60,
    h = 90,
    speed = 240,
    vector = moveVectors[MOVE.NONE]:copy(),
    color = COLOR.ORANGE
  }, AutoBounce)

  local objects = {
    rect1,
    rect2,
    rect3,
    rect4,
    rect5,
    rect6,
    rect7,
    RectStatic:new({
      id = 'wall',
      x = 0,
      y = 0,
      w = 800,
      h = 3,
    }),
    RectStatic:new({
      id = 'wall',
      x = 0,
      y = 3,
      w = 3,
      h = 594,
    }),
    RectStatic:new({
      id = 'wall',
      x = 797,
      y = 3,
      w = 3,
      h = 594,
    }),
    RectStatic:new({
      id = 'wall',
      x = 0,
      y = 597,
      w = 800,
      h = 3,
    })
  }

  return objects
end

return demo