local _, CONTROL, _, _ = require("Const")()
local _, testControl = require("Control")()

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
  _constructors = {
    Animator = function(self)
      self[RIGHT] = {}
      for i = 1, 6 do
        table.insert(self[RIGHT], love.graphics.newImage("demo/walkingBoy/img/move" .. STATE[RIGHT].n .. i .. ".png"))
      end
      self[LEFT] = self[RIGHT]
      self[FACE] = {}
      for i = 1, 6 do
        table.insert(self[FACE], love.graphics.newImage("demo/walkingBoy/img/move" .. STATE[FACE].n .. i .. ".png"))
      end
      self[BACK] = {}
      for i = 1, 6 do
        table.insert(self[BACK], love.graphics.newImage("demo/walkingBoy/img/move" .. STATE[BACK].n .. i .. ".png"))
      end
      self._state = RIGHT
      self._step = 1
      self._time = 0
    end
  },

  update = function(self, ctrl, dt)
    local animate = false
    if testControl(ctrl, CONTROL.RIGHT) then
      self._state = RIGHT
      animate = true
    elseif testControl(ctrl, CONTROL.LEFT) then
      self._state = LEFT
      animate = true
    elseif testControl(ctrl, CONTROL.UP) then
      self._state = BACK
      animate = true
    elseif testControl(ctrl, CONTROL.DOWN) then
      self._state = FACE
      animate = true
    end
    if animate then
      self._time = self._time + dt
      if self._time > 0.2 then
        self._step = self._step + 1
        if self._step > #self[self._state] then
          self._step = 1
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
    love.graphics.draw(self[self._state][self._step], c.x + ((1 - STATE[self._state].f) * self.w) / 2, c.y, 0,
      4 * STATE[self._state].f, 4)
  end
}

return function()
  return Boy
end
