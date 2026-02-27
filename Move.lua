-- IMPORTS
require("math-ext")
local Coord, _, _, Vector = require("Couple")()
local _, CONTROL, EVENT, MOVE = require("Const")()
-- local debug = require("Debug")()
-- END IMPORTS

local moveVectors = {
	[MOVE.UP] = Vector:new({ x = 0, y = -1 }),
	[MOVE.DOWN] = Vector:new({ x = 0, y = 1 }),
	[MOVE.LEFT] = Vector:new({ x = -1, y = 0 }),
	[MOVE.RIGHT] = Vector:new({ x = 1, y = 0 }),
	[MOVE.NONE] = Vector:new({ x = 0, y = 0 })
}

local IAMove = {
	IAMove = true,
	_new = function (self)
		self._c = Coord:new({x = self.x, y = self.y})  -- internal coord
		self._d = self._c:copy() -- internal destination
		self.d = self._d:copy() -- visible destination
	end,
	control = function (self, ctrl, dt)
		if self._control then
			self:_control(ctrl, dt)
		end
		return self:move(ctrl, dt)
	end,
	move = function (self, ctrl, dt)
		if ctrl >= CONTROL.ACT3 then ctrl = ctrl - CONTROL.ACT3 end
		if ctrl >= CONTROL.ACT2 then ctrl = ctrl - CONTROL.ACT2 end
		if ctrl >= CONTROL.ACT1 then ctrl = ctrl - CONTROL.ACT1 end
		if ctrl >= CONTROL.UP then
			ctrl = ctrl - CONTROL.UP
			self.vector = self.vector + moveVectors[MOVE.UP]
		end
		if ctrl >= CONTROL.DOWN then
			ctrl = ctrl - CONTROL.DOWN
			self.vector = self.vector + moveVectors[MOVE.DOWN]
		end
		if ctrl >= CONTROL.LEFT then
			ctrl = ctrl -CONTROL.LEFT
			self.vector = self.vector + moveVectors[MOVE.LEFT]
		end
		if ctrl >= CONTROL.RIGHT then
			self.vector = self.vector + moveVectors[MOVE.RIGHT]
		end
		if self.getMove then
			self.vector = self:getMove(self.vector, ctrl, dt)
		end
		if self._move then
			self:_move(ctrl, dt)
		end
		self.vector = (self.vector * (self.speed or 1) * dt)
		self._d = self._c + self.vector
		self.d = self._d:round()
		if self.eventManager then
			if self._d ~= self._c then
				self.eventManager:fire(EVENT.MOVE, self)
			end
		end
	end,
	commit = function (self, next, ...)
		if self._commit then
			self:_commit()
		end
		if self.d ~= self._d:round() then
			self._d = self.d:copy()
		end
		self._c = self._d:copy()
		self.x = math.round(self._c.x)
		self.y = math.round(self._c.y)
		self.vector = self:_initVector()
		if next then
			return next:commit(...)
		end
		return true
	end,
	_initVector = function (_)
		return moveVectors[MOVE.NONE]:copy()
	end
}

local IMoveX = {
	_move = function (self, _, _)
		self.vector.y = 0
	end,
}

local IMoveY = {
	_move = function (self, _, _)
		self.vector.x = 0
	end,
}

local IMove = {}

local IMoveNot = {
	_move = function (self)
		self.vector = Vector:new({ x = 0, y = 0 })
	end,
}

return function () return
	moveVectors,
	IAMove,
	IMove,
	IMoveNot,
	IMoveX,
	IMoveY
end