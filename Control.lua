-- IMPORTS
require("math-ext")
local new, Trait = require("POO")()
local COLOR, CONTROL, MOVE = require("Const")()
local IAMove, IMoveMove, IMoveNot, moveVectors = require("Move")()
-- END IMPORTS

local IAControl = Trait:new({
	control = function (self, m, dt)
		if self._control then
			self:_control(m, dt)
		end
	end
})

local IControlNot = Trait:new({
	_control = function (self)
		self.vector = moveVectors[MOVE.NONE]
	end
})

local IControl2D = Trait:new({
	_control = function (self, m, dt)
		if m >= CONTROL.UP then
			m = m - CONTROL.UP
			self.vector = self.vector + moveVectors[CONTROL.UP]
		end
		if m >= CONTROL.DOWN then
			m = m - CONTROL.DOWN
			self.vector = self.vector + moveVectors[CONTROL.DOWN]
		end
		if m >= CONTROL.LEFT then
			m = m -CONTROL.LEFT
			self.vector = self.vector + moveVectors[CONTROL.LEFT]
		end
		if m >= CONTROL.RIGHT then
			self.vector = self.vector + moveVectors[CONTROL.RIGHT]
		end
		self.vector = (self.vector * self.speed * dt)
	end,
})

local IControl1DX = Trait:new({
	_control = function (self, m, dt)
		if m >= CONTROL.UP then
			m = m - CONTROL.UP
		end
		if m >= CONTROL.DOWN then
			m = m - CONTROL.DOWN
		end
		if m >= CONTROL.LEFT then
			m = m -CONTROL.LEFT
			self.vector = self.vector + moveVectors[CONTROL.LEFT]
		end
		if m >= CONTROL.RIGHT then
			self.vector = self.vector + moveVectors[CONTROL.RIGHT]
		end
		self.vector = (self.vector * self.speed * dt)
	end
})

local IControl1DY = Trait:new({
	_control = function (self, m, dt)
		if m >= CONTROL.UP then
			m = m - CONTROL.UP
			self.vector = self.vector + moveVectors[CONTROL.UP]
		end
		if m >= CONTROL.DOWN then
			self.vector = self.vector + moveVectors[CONTROL.DOWN]
		end
		self.vector = self.vector * self.speed * dt
	end
})

return function () return
  IAControl,
  IControl1DX,
  IControl1DY,
  IControl2D,
  IControlNot
end