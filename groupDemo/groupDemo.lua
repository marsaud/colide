-- local debug = require("Debug")()
local Class = require("OOP")()
local _, IEventCatcher = require("Event")()
local COLOR, _, _, MOVE = require("Const")()
local _, _, IAControl, IControlMove = require("Control")()
local AGameUIObject, Group = require("Utils")()
local IADraw, IRectFill, IRectLine = require("Draw")()
local IAPlace = require("Place")()
local moveVectors, IAMove, IMove, _, _, _ = require("Move")()
local IACollide, ICollideBlocker, _, _, _, ICollidePusher = require("Collide")()

local function groupDemo()
  local RectNoMove = AGameUIObject:new(IControlMove, ICollidePusher, IRectLine)
  local RectStatic = AGameUIObject:new(ICollideBlocker, IRectFill)

  local Rect2D = AGameUIObject:new(IControlMove, IMove, ICollidePusher, IRectLine)
  local RectPassive = AGameUIObject:new(ICollidePusher, IRectLine)

  local autoMove = function(time)
    local AutoMove = {
      stateIndex = 1,
      stateTimer = 0,
      states = {
        moveVectors[MOVE.UP],
        moveVectors[MOVE.RIGHT],
        moveVectors[MOVE.DOWN],
        moveVectors[MOVE.LEFT],
      },
      _move = function(self, _, dt)
        self.stateTimer = self.stateTimer + dt
        if self.stateTimer > time then
          self.stateTimer = 0
          self.stateIndex = self.stateIndex + 1
          if self.stateIndex > #self.states then
            self.stateIndex = 1
          end
        end
        return self.states[self.stateIndex]:copy()
      end,
    }
    return AutoMove
  end

  local ControlGroup = Group:new(
    IACollide,
    IAControl,
    IAMove,
    IAPlace,
    IControlMove,
    IMove
  )

  local PassiveGroup = Group:new(
    IACollide,
    IAControl,
    IAMove,
    IAPlace,
    IControlMove
  )

  local group = ControlGroup:new({
    id = "group",
    x = 25,
    y = 100,
    w = 0,
    h = 0,
    speed = 240,
    vector = moveVectors[MOVE.NONE]:copy(),
  })

  group:add(
    RectNoMove:new({
      id = "red",
      x = 0,
      y = 110,
      w = 50,
      h = 50,
      speed = 20,
      vector = moveVectors[MOVE.NONE]:copy(),
      color = COLOR.RED,
    }, autoMove(1.80)),
    RectNoMove:new({
      id = "green",
      x = 25,
      y = 0,
      w = 50,
      h = 50,
      speed = 40,
      vector = moveVectors[MOVE.NONE]:copy(),
      color = COLOR.GREEN,
    } --, autoMove(0.60)
    ),
    RectNoMove:new({
      id = "blue",
      x = 110,
      y = 55,
      w = 50,
      h = 50,
      speed = 80,
      vector = moveVectors[MOVE.NONE]:copy(),
      color = COLOR.BLUE,
    } --, autoMove(0.30)
    )
  )

  local pGroup = PassiveGroup:new({
    id = "pGroup",
    x = 400,
    y = 200,
    w = 0,
    h = 0,
    speed = 90,
    vector = moveVectors[MOVE.NONE]:copy(),
  })

  pGroup:add(
    RectNoMove:new(
      {
        id = "magenta",
        x = 0,
        y = 110,
        w = 50,
        h = 50,
        speed = 20,
        vector = moveVectors[MOVE.NONE]:copy(),
        color = COLOR.MAGENTA,
      }
    -- ,autoMove(1.80)
    ),
    RectNoMove:new(
      {
        id = "yellow",
        x = 25,
        y = 0,
        w = 50,
        h = 50,
        speed = 60,
        vector = moveVectors[MOVE.NONE]:copy(),
        color = COLOR.YELLOW,
      }
    -- , autoMove(0.60)
    ),
    RectNoMove:new(
      {
        id = "cyan",
        x = 110,
        y = 55,
        w = 50,
        h = 50,
        speed = 120,
        vector = moveVectors[MOVE.NONE]:copy(),
        color = COLOR.CYAN,
      }
    -- , autoMove(0.30)
    )
  )

  local rect1 = Rect2D:new({
    id = "R1",
    x = 400,
    y = 50,
    w = 50,
    h = 50,
    speed = 120,
    vector = moveVectors[MOVE.NONE]:copy(),
    color = COLOR.RED,
  })

  local rect4 = RectPassive:new({
    id = "R2",
    x = 500,
    y = 50,
    w = 50,
    h = 50,
    speed = 90,
    vector = moveVectors[MOVE.NONE]:copy(),
    color = COLOR.MAGENTA,
  })

  local objects = {
    -- rect1,
    -- rect4,
    group,
    pGroup,
    RectStatic:new({
      id = "wall",
      x = 0,
      y = 0,
      w = 800,
      h = 3,
    }),
    RectStatic:new({
      id = "wall",
      x = 0,
      y = 3,
      w = 3,
      h = 594,
    }),
    RectStatic:new({
      id = "wall",
      x = 797,
      y = 3,
      w = 3,
      h = 594,
    }),
    RectStatic:new({
      id = "wall",
      x = 0,
      y = 597,
      w = 800,
      h = 3,
    }),
  }

  return objects
end

return groupDemo
