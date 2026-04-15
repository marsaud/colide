-- local debug = require("Debug")()
local Class = require("OOP")()
local _, IEventCatcher = require("Event")()
local COLOR, _, _, MOVE = require("Const")()
local _, _, IAControl, _ = require("Control")()
local AGameUIObject, Group = require("Utils")()
local IADraw, IRectFill, IRectLine = require("Draw")()
local IAPlace = require("Place")()
local moveVectors, IAMove, IMove, _, _, _ = require("Move")()
local IACollide, ICollideBlocker, _, _, _, ICollidePusher = require("Collide")()

local function demo()
  local RectNoMove =
    Class(IAPlace, IAMove, IADraw, IRectLine, IACollide, ICollidePusher, IEventCatcher)
  local RectStatic = AGameUIObject:new(ICollideBlocker, ICollidePusher, IRectFill)

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

  local ControlGroup = Group:new(IAControl, IAPlace, IMove, {
    _control = function(self, ctrl, dt)
      local v = self:_move(ctrl, dt) * (self.speed or 0) * dt
      for _, o in ipairs(self._group) do
        if o.move then
          o:move(ctrl, dt, v, self.speed)
        end
      end
    end,
    commit = function(self)
      self.vector = moveVectors[MOVE.NONE]:copy()
    end,
  })

  local group = ControlGroup:new({
    x = 0,
    y = 0,
    w = 0,
    h = 0,
    speed = 240,
    vector = moveVectors[MOVE.NONE]:copy(),
  })

  group:add(
    RectNoMove:new({
      id = "red",
      x = 25,
      y = 300,
      w = 50,
      h = 50,
      speed = 360,
      vector = moveVectors[MOVE.NONE]:copy(),
      color = COLOR.RED,
    }, autoMove(0.10)),
    RectNoMove:new({
      id = "green",
      x = 25,
      y = 100,
      w = 50,
      h = 50,
      speed = 90,
      vector = moveVectors[MOVE.NONE]:copy(),
      color = COLOR.GREEN,
    }, autoMove(1)),
    RectNoMove:new({
      id = "blue",
      x = 125,
      y = 100,
      w = 50,
      h = 50,
      speed = 150,
      vector = moveVectors[MOVE.NONE]:copy(),
      color = COLOR.BLUE,
    }, autoMove(0.20))
  )

  local objects = {
    group,
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

return demo
