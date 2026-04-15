-- local debug = require("Debug")()
---@diagnostic disable-next-line: undefined-global
local bit = bit

require("math-ext")
local _, _, _, Vector = require("Couple")()
local _, CONTROL, EVENT, MOVE = require("Const")()
local _, testControl = require("Control")()

local moveVectors = {
  [MOVE.UP] = Vector:new({ x = 0, y = -1 }),
  [MOVE.DOWN] = Vector:new({ x = 0, y = 1 }),
  [MOVE.LEFT] = Vector:new({ x = -1, y = 0 }),
  [MOVE.RIGHT] = Vector:new({ x = 1, y = 0 }),
  [MOVE.NONE] = Vector:new({ x = 0, y = 0 }),
}

--[[
	_move(
		self
		ctrl: (number) control bit mask
		dt: (number) love provided delta time
	)
]]

local IAMove = {
  _constructors = {
    IAMove = function(self)
      self._d = self._c:copy() -- internal destination
      self.d = self._d:copy() -- visible destination
    end,
  },

  move = function(self, ctrl, dt, v)
    if self._move then
      self.vector = self:_move(ctrl, dt) * (self.speed or 0) * dt
    end
    if v then
      v = v:copy()
      self.vector = self.vector + v
    end
    self._d = self._c + self.vector
    self.d = self._d:round()
    if self.eventManager then
      if self._d ~= self._c then
        self.eventManager:fire(EVENT.MOVE, self)
      end
    end
  end,

  commit = function(self)
    if self._commit then
      self:_commit()
    end
    return true
  end,

  _commit = function(self)
    if self.d ~= self._d:round() then
      self._d = self.d:copy()
    end
    self._c = self._d:copy()
    self.x = math.round(self._c.x)
    self.y = math.round(self._c.y)
    self.vector = self:_initVector()
  end,

  _initVector = function(_)
    return moveVectors[MOVE.NONE]:copy()
  end,
}

local IMove = {
  _move = function(self, ctrl, _)
    if self.vector == nil then
      self.vector = moveVectors[MOVE.NONE]:copy()
    end
    if testControl(ctrl, CONTROL.UP) then
      self.vector = self.vector + moveVectors[MOVE.UP]
    end
    if testControl(ctrl, CONTROL.DOWN) then
      self.vector = self.vector + moveVectors[MOVE.DOWN]
    end
    if testControl(ctrl, CONTROL.LEFT) then
      self.vector = self.vector + moveVectors[MOVE.LEFT]
    end
    if testControl(ctrl, CONTROL.RIGHT) then
      self.vector = self.vector + moveVectors[MOVE.RIGHT]
    end
    return self.vector
  end,
}

local IMoveX = {
  _move = function(self, ctrl, _)
    if self.vector == nil then
      self.vector = moveVectors[MOVE.NONE]:copy()
    end
    if testControl(ctrl, CONTROL.LEFT) then
      self.vector = self.vector + moveVectors[MOVE.LEFT]
    end
    if testControl(ctrl, CONTROL.RIGHT) then
      self.vector = self.vector + moveVectors[MOVE.RIGHT]
    end
    return self.vector
  end,
}

local IMoveY = {
  _move = function(self, ctrl, _)
    if self.vector == nil then
      self.vector = moveVectors[MOVE.NONE]:copy()
    end
    if testControl(ctrl, CONTROL.UP) then
      self.vector = self.vector + moveVectors[MOVE.UP]
    end
    if testControl(ctrl, CONTROL.DOWN) then
      self.vector = self.vector + moveVectors[MOVE.DOWN]
    end
    return self.vector
  end,
}

local IMoveNot = {
  _move = function(self, _, _)
    return moveVectors[MOVE.NONE]:copy()
  end,
}

return function()
  return moveVectors, IAMove, IMove, IMoveNot, IMoveX, IMoveY
end
