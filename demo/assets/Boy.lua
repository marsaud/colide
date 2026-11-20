local L = require("lib")
local C = require("Const")
local CONTROL = C.CONTROL
local Control = require("Control")
local testControl = Control.testControl

local source = debug.getinfo(1, "S").source
local dir = source:match("^@(.*/)") or ""

local FACE = "face"
local BACK = "back"
local RIGHT = "right"
local LEFT = "left"

local STATE = {
  [FACE] = {
    n = "face",
    f = 1,
  },
  [BACK] = {
    n = "back",
    f = 1,
  },
  [RIGHT] = {
    n = "side",
    f = 1,
  },
  [LEFT] = {
    n = "side",
    f = -1,
  },
}

local Boy = {
  __constructors = {
    Boy = function(self)
      self[RIGHT] = {}
      for i = 1, 6 do
        table.insert(
          self[RIGHT],
          love.graphics.newImage(dir .. "walkingBoy/img/move" .. STATE[RIGHT].n .. i .. ".png")
        )
      end
      self[LEFT] = self[RIGHT]
      self[FACE] = {}
      for i = 1, 6 do
        table.insert(
          self[FACE],
          love.graphics.newImage(dir .. "walkingBoy/img/move" .. STATE[FACE].n .. i .. ".png")
        )
      end
      self[BACK] = {}
      for i = 1, 6 do
        table.insert(
          self[BACK],
          love.graphics.newImage(dir .. "walkingBoy/img/move" .. STATE[BACK].n .. i .. ".png")
        )
      end
      self._state = {
        dir = RIGHT,
        step = 1
      }
      self._time = 0
    end,
  },

  _update = function(self, ctrl, dt)
    local animate = false
    if testControl(ctrl, CONTROL.RIGHT) then
      self._state.dir = RIGHT
      animate = true
    elseif testControl(ctrl, CONTROL.LEFT) then
      self._state.dir = LEFT
      animate = true
    elseif testControl(ctrl, CONTROL.UP) then
      self._state.dir = BACK
      animate = true
    elseif testControl(ctrl, CONTROL.DOWN) then
      self._state.dir = FACE
      animate = true
    end
    if animate then
      self._time = self._time + dt
      if self._time > 0.2 then
        self._state.step = self._state.step + 1
        if self._state.step > #self[self._state.dir] then
          self._state.step = 1
        end
        self._time = self._time - 0.2
      end
    end
  end,

  _draw = function(self, id)
    local c
    if self.c then
      c = self:c()
    else
      c = self
    end
    love.graphics.draw(
      self[self._state.dir][self._state.step],
      c.x + ((1 - STATE[self._state.dir].f) * self.w) / 2,
      c.y,
      0,
      4 * STATE[self._state.dir].f,
      4
    )
  end,
}

return {
  Boy = Boy,
}
