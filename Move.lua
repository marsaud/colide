-- local debug = require("Debug").debug

require("math-ext")
local Couple = require("Couple")
local Vector = Couple.Vector
local C = require("Const")
local CONTROL, EVENT, MOVE = C.CONTROL, C.EVENT, C.MOVE
local Control = require("Control")
local testControl = Control.testControl

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
      if not self.vector then
        self.vector = self:_initVector()
      end
    end,
  },

  move = function(self, id, ctrl, dt, v)
    if self._move then
      self.vector = self:_move(id, ctrl, dt) * (self.speed or 0) * dt
    end
    if v then
      v = v:copy()
      self.vector = self.vector + v
    end
    self._d = self._c + self.vector
    if self._d ~= self._c then
      self:fireMove(id)
    end
  end,

  commit = function(self, id)
    if self._commit then
      self:_commit(id)
    end
    return true
  end,

  _commit = function(self, id)
    self._c = self._d:copy()
    if self._initVector then
      self.vector = self:_initVector()
    end
  end,

  v = function(self, value, forceMover)
    if self._mover then
      if value then
        if forceMover then
          self._mover.vector = value - self.vector
        else
          self.vector = value - self._mover.vector
        end
      end
      return self.vector + self._mover.vector
    else
      if value then
        self.vector = value:copy()
      end
      return self.vector
    end
  end,

  fireMove = function(self, id, ...)
    if self.eventManager then
      local moving = self._mover or self
      return self.eventManager:fire(EVENT.MOVE, id, moving, ...)
    else
      return true
    end
  end,

  _initVector = function(_)
    return moveVectors[MOVE.NONE]:copy()
  end,

  setMover = function(self, value)
    self._mover = value
  end,

  removeMover = function(self)
    self._mover = nil
  end,
}

local IMove = {
  _move = function(self, id, ctrl, _)
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
  _move = function(self, id, ctrl, _)
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
  _move = function(self, id, ctrl, _)
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
  _move = function(self, id, _, _)
    return moveVectors[MOVE.NONE]:copy()
  end,
}

return {
  moveVectors = moveVectors,
  IAMove = IAMove,
  IMove = IMove,
  IMoveNot = IMoveNot,
  IMoveX = IMoveX,
  IMoveY = IMoveY,
}
